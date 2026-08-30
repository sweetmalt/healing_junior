import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/ctrl.dart';
import 'package:healing_junior/services/eeg_data_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// 把 EEGDataModel 通过本地 TCP 端口广播给其他进程的本地服务
/// （当前在 EEGController 中未启用 broadcastData，保留以备后续使用）
class BroadcastService extends GetxService {
  static const int DEFAULT_PORT = 51886;
  ServerSocket? _server;
  final List<Socket> _clients = [];
  bool _isRunning = false;

  @override
  void onInit() {
    startBroadcast();
    super.onInit();
  }

  @override
  void onClose() {
    stopBroadcast();
    super.onClose();
  }

  Future<void> startBroadcast({int port = DEFAULT_PORT}) async {
    if (_isRunning) return;
    try {
      _server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
      _isRunning = true;
      _server!.listen(
        (client) {
          _clients.add(client);
          client.done.then((_) => _clients.remove(client));
        },
        onError: (e) {
          debugPrint('广播服务器错误: $e');
        },
      );
      debugPrint('广播服务已启动，端口: $port');
    } catch (e) {
      debugPrint('启动广播服务失败: $e');
    }
  }

  void stopBroadcast() {
    _isRunning = false;
    for (var client in _clients) {
      client.close();
    }
    _clients.clear();
    _server?.close();
    _server = null;
  }

  void broadcastData(EEGDataModel data) {
    if (!_isRunning || _clients.isEmpty) return;
    try {
      String jsonString = '${jsonEncode(data.toJson())}\n';
      List<int> dataBytes = utf8.encode(jsonString);
      debugPrint('广播数据: $dataBytes');
      for (var client in _clients) {
        client.add(dataBytes);
      }
    } catch (e) {
      debugPrint('广播数据错误: $e');
    }
  }
}

/// 多模头带串口协议解析器
///
/// 帧格式：AA 55 LEN [Payload] Checksum
///   - AA 55: 帧头
///   - LEN:   Payload 长度
///   - Payload: 有效数据
///   - Checksum = sum(Payload) & 0xFF（仅算 Payload，不含 AA 55 LEN）
///
/// 支持的 LEN：
///   - 0x22 (34 字节): 融合数据包（Type = 0x01）
///   - 0x11 (17 字节): 六轴数据包（Type = 0x02），App 不消费，解析后丢弃
///
/// 设计要点：
///   - 使用状态机按字节解析，BLE 一次 read 不一定刚好一整包
///   - LEN 不合法立即回到 WAIT_AA，避免缓冲区错位
///   - Checksum 校验失败立即回到 WAIT_AA
///   - 融合包解析完成后调 _publishData() 推给 EEGController
///   - 六轴包解析完成后不入模型、不发布（App 用不到）
class MultimodalHeadbandParser extends GetxService {
  // 状态常量
  static const int STATE_WAIT_AA = 0; // 等待帧头第一字节
  static const int STATE_WAIT_55 = 1; // 等待帧头第二字节
  static const int STATE_WAIT_LEN = 2; // 等待长度字节
  static const int STATE_READ_PAYLOAD = 3; // 读取 Payload
  static const int STATE_READ_CHECKSUM = 4; // 读取校验和

  // 包类型
  static const int PACKET_TYPE_FUSION = 0x01; // 融合数据包
  static const int PACKET_TYPE_IMU = 0x02; // 六轴数据包

  // 合法的 LEN 值
  static const int LEN_FUSION = 0x22; // 34 字节
  static const int LEN_IMU = 0x11; // 17 字节

  // 状态变量
  int _state = STATE_WAIT_AA;
  int _payloadLength = 0;
  int _payloadBytesReceived = 0;
  int _payloadSum = 0;
  final List<int> _payload = List.filled(64, 0); // 最大 34 字节，留余量
  final EEGDataModel _tempModel = EEGDataModel();

  /// 喂入从 BLE 通道读到的字节流
  void addBytes(List<int> bytes) {
    for (var byte in bytes) {
      _parseByte(byte);
    }
  }

  void _parseByte(int byte) {
    switch (_state) {
      case STATE_WAIT_AA:
        if (byte == 0xAA) _state = STATE_WAIT_55;
        break;

      case STATE_WAIT_55:
        if (byte == 0x55) {
          _state = STATE_WAIT_LEN;
        } else if (byte == 0xAA) {
          // 兼容连续 AA 的情况（例如 AA AA 55）：保留在等 55
          _state = STATE_WAIT_55;
        } else {
          _state = STATE_WAIT_AA;
        }
        break;

      case STATE_WAIT_LEN:
        // 校验 LEN 合法性：仅接受 0x22 / 0x11
        if (byte == LEN_FUSION || byte == LEN_IMU) {
          _payloadLength = byte;
          _payloadBytesReceived = 0;
          _payloadSum = 0;
          _state = STATE_READ_PAYLOAD;
        } else {
          // 非法 LEN：丢弃当前帧，重新等 AA
          _state = STATE_WAIT_AA;
          // 如果这一字节恰好是 0xAA，下一轮会自然进入 WAIT_55
          if (byte == 0xAA) {
            _state = STATE_WAIT_55;
          }
        }
        break;

      case STATE_READ_PAYLOAD:
        _payload[_payloadBytesReceived++] = byte;
        _payloadSum = (_payloadSum + byte) & 0xFF; // 累加并保持 8 位
        if (_payloadBytesReceived >= _payloadLength) {
          _state = STATE_READ_CHECKSUM;
        }
        break;

      case STATE_READ_CHECKSUM:
        // Checksum = sum(Payload) & 0xFF
        int computed = _payloadSum & 0xFF;
        if (computed == (byte & 0xFF)) {
          _parsePayload(_payload.sublist(0, _payloadLength));
        } else {
          debugPrint('校验和错误: 期望 $computed 收到 ${byte & 0xFF}');
        }
        _state = STATE_WAIT_AA;
        break;
    }
  }

  /// 按 Payload[0] 包类型分发
  void _parsePayload(List<int> data) {
    if (data.isEmpty) return;
    int type = data[0];
    switch (type) {
      case PACKET_TYPE_FUSION:
        _parseFusionPacket(data);
        break;
      case PACKET_TYPE_IMU:
        // 六轴包：App 不消费，解析后直接丢弃
        _parseImuPacket(data);
        break;
      default:
        debugPrint('未知包类型: 0x${type.toRadixString(16)}');
    }
  }

  /// 解析融合数据包（34 字节 Payload）
  /// 字段定义见硬件协议文档 3.2 节
  void _parseFusionPacket(List<int> data) {
    // 长度校验
    if (data.length != LEN_FUSION) return;
    if (data[0] != PACKET_TYPE_FUSION) return;

    int i = 0;
    // Payload[0] = PacketType (uint8, 固定 0x01)
    i += 1;
    // Payload[1] = Signal (uint8)
    _tempModel.poorSignal = data[i] & 0xFF;
    i += 1;
    // Payload[2-4] = Delta (uint24 大端)
    _tempModel.delta = _readUint24BE(data, i);
    i += 3;
    // Payload[5-7] = Theta (uint24 大端)
    _tempModel.theta = _readUint24BE(data, i);
    i += 3;
    // Payload[8-10] = LowAlpha (uint24 大端)
    int lowAlpha = _readUint24BE(data, i);
    i += 3;
    // Payload[11-13] = HighAlpha (uint24 大端)
    int highAlpha = _readUint24BE(data, i);
    i += 3;
    _tempModel.alpha = lowAlpha + highAlpha;
    // Payload[14-16] = LowBeta (uint24 大端)
    int lowBeta = _readUint24BE(data, i);
    i += 3;
    // Payload[17-19] = HighBeta (uint24 大端)
    int highBeta = _readUint24BE(data, i);
    i += 3;
    _tempModel.beta = lowBeta + highBeta;
    // Payload[20-22] = LowGamma (uint24 大端)
    int lowGamma = _readUint24BE(data, i);
    i += 3;
    // Payload[23-25] = MiddleGamma (uint24 大端)
    int midGamma = _readUint24BE(data, i);
    i += 3;
    _tempModel.gamma = lowGamma + midGamma;
    // Payload[26] = AttentionCode (uint8, 固定 0x04)
    i += 1;
    // Payload[27] = Attention (uint8)
    _tempModel.attention = data[i] & 0xFF;
    i += 1;
    // Payload[28] = MeditationCode (uint8, 固定 0x05)
    i += 1;
    // Payload[29] = Meditation (uint8)
    _tempModel.meditation = data[i] & 0xFF;
    i += 1;
    // Payload[30] = HeartRate (uint8)
    _tempModel.heartRate = data[i] & 0xFF;
    i += 1;
    // Payload[31] = SpO2 (uint8)
    _tempModel.spO2 = data[i] & 0xFF;
    i += 1;
    // Payload[32] = ForeheadTemp (uint8)
    _tempModel.foreheadTemp = data[i] & 0xFF;
    i += 1;
    // Payload[33] = Battery (uint8)
    _tempModel.battery = data[i] & 0xFF;

    // 推送给 EEGController
    _publishData();
  }

  /// 解析六轴数据包（17 字节 Payload）
  /// 字段定义见硬件协议文档 4.2 节
  /// App 不消费这些数据，解析后直接丢弃（不入模型）
  void _parseImuPacket(List<int> data) {
    if (data.length != LEN_IMU) return;
    if (data[0] != PACKET_TYPE_IMU) return;

    // Payload[0] = PacketType (uint8)
    // Payload[1-4] = SampleCount (uint32 大端) - 不消费
    // Payload[5-6] = AccX (int16 大端) - 不消费
    // Payload[7-8] = AccY (int16 大端) - 不消费
    // Payload[9-10] = AccZ (int16 大端) - 不消费
    // Payload[11-12] = GyroX (int16 大端) - 不消费
    // Payload[13-14] = GyroY (int16 大端) - 不消费
    // Payload[15-16] = GyroZ (int16 大端) - 不消费
    //
    // 当前 App 完全不消费六轴数据；此处留作空实现以备后续扩展。
    // 若将来需要消费，请新增 _tempModel.accX 等字段并在此赋值。
  }

  /// 读取 3 字节大端无符号整数
  int _readUint24BE(List<int> data, int index) {
    return ((data[index] & 0xFF) << 16) |
        ((data[index + 1] & 0xFF) << 8) |
        (data[index + 2] & 0xFF);
  }

  void _publishData() {
    // 复制当前数据到新对象，避免后续修改影响已发布的数据
    final eegData = _tempModel.copy();
    Get.find<EEGController>().updateEEGData(eegData);
    // 广播（暂未启用，保留接口）
    // Get.find<BroadcastService>().broadcastData(eegData);
  }
}

/// 脑电数据控制器（聚合状态）
/// - eegData: 最近一次融合包的完整数据（供 UI 展示）
/// - updateEEGData: 收到融合包后立即推送给 MyCtrl（每包一推）
class EEGController extends GetxController {
  final eegData = EEGDataModel().obs;
  final MyCtrl myCtrl = Get.put(MyCtrl());

  void updateEEGData(EEGDataModel data) {
    // 更新 UI 展示用的最新数据
    eegData.value = data;

    // 读取 5 波段（alpha/beta/gamma 已是聚合值）
    final att = data.attention?.toDouble() ?? 0.0;
    final med = data.meditation?.toDouble() ?? 0.0;
    final delta = data.delta?.toDouble() ?? 0.0;
    final theta = data.theta?.toDouble() ?? 0.0;
    final alpha = data.alpha?.toDouble() ?? 0.0;
    final beta = data.beta?.toDouble() ?? 0.0;
    final gamma = data.gamma?.toDouble() ?? 0.0;

    // 每包立即推送给 MyCtrl（不再走 1 秒定时器窗口）
    myCtrl.pushData([att, med, delta, theta, alpha, beta, gamma]);
  }
}

class MyBluetoothService extends GetxService {
  static const String TARGET_DEVICE_NAME_PREFIX = 'HR-'; // 目标设备名称前缀

  final scanResults = <ScanResult>[].obs;
  final connectionState = BluetoothConnectionState.disconnected.obs;
  BluetoothDevice? connectedDevice;

  /// 正在连接中的设备 remoteId（用于 UI 显示 loading 状态）。
  /// 连接成功转为 connectedDevice 后会清空；连接失败也会清空。
  final RxnString connectingDeviceId = RxnString();

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  final List<StreamSubscription<List<int>>> _charSubscriptions = [];
  final List<BluetoothCharacteristic> _notifyingCharacteristics = [];

  @override
  void onClose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    disconnect();
    super.onClose();
  }

  // 请求权限
  Future<bool> requestPermissions() async {
    var status = await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
    return status.values.every((s) => s.isGranted);
  }

  // 开始扫描
  Future<void> startScan() async {
    if (!await requestPermissions()) {
      Get.snackbar('权限错误', '需要蓝牙和位置权限才能扫描');
      return;
    }

    // 不再清空 scanResults：保留已连接设备在列表顶部，新增设备增量加入
    try {
      await FlutterBluePlus.startScan();

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (var result in results) {
            if (result.device.platformName.isNotEmpty && result.device.platformName.startsWith(TARGET_DEVICE_NAME_PREFIX)) {
              if (!scanResults.any((r) => r.device.remoteId == result.device.remoteId)) {
                scanResults.add(result);
              }
            }
          }
        },
        onError: (e) {
          Get.snackbar('扫描错误', e.toString());
        },
      );
    } catch (e) {
      Get.snackbar('扫描启动失败', e.toString());
    }
    Future.delayed(const Duration(seconds: 5), () {
      stopScan();
    });
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    stopScan();

    // 切换设备：主动断开旧连接，避免依赖 SDK 隐式行为
    if (connectedDevice != null &&
        connectedDevice!.remoteId != device.remoteId) {
      final old = connectedDevice!;
      // 先清状态，避免旧设备的 disconnect 回调误把新设备的状态清掉
      connectedDevice = null;
      connectingDeviceId.value = null;
      connectionState.value = BluetoothConnectionState.disconnected;
      await _clearCharacteristicSubscriptions();
      try {
        await old.disconnect();
      } catch (_) {
        // 旧设备断开失败不影响新设备连接
      }
    } else if (connectedDevice?.remoteId == device.remoteId &&
        connectionState.value == BluetoothConnectionState.connected) {
      // 同一台设备且已连接：直接返回，不重复连接
      return;
    }

    connectedDevice = device;
    connectingDeviceId.value = device.remoteId.str;

    try {
      await device.connect(license: License.nonprofit, autoConnect: false);

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) async {
        connectionState.value = state;
        if (state == BluetoothConnectionState.disconnected) {
          connectedDevice = null;
          await _clearCharacteristicSubscriptions();
        }
      });

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);

            final sub = characteristic.lastValueStream.listen((value) {
              Get.find<MultimodalHeadbandParser>().addBytes(value);
            });
            _charSubscriptions.add(sub);
            _notifyingCharacteristics.add(characteristic);
          }
        }
      }
      // 连接成功（指 discoverServices 走完、订阅通道就绪），清除 connecting 标记
      connectingDeviceId.value = null;
    } catch (e) {
      // 失败：复位所有状态
      connectingDeviceId.value = null;
      connectedDevice = null;
      connectionState.value = BluetoothConnectionState.disconnected;
      Get.snackbar(
        '连接失败',
        '${device.platformName.isNotEmpty ? device.platformName : "该设备"} 连接出错：${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _clearCharacteristicSubscriptions() async {
    final subs = List<StreamSubscription<List<int>>>.from(_charSubscriptions);
    final chars = List<BluetoothCharacteristic>.from(_notifyingCharacteristics);
    for (var sub in subs) {
      try {
        await sub.cancel();
      } catch (_) {}
    }
    _charSubscriptions.clear();
    for (var c in chars) {
      try {
        await c.setNotifyValue(false);
      } catch (_) {}
    }
    _notifyingCharacteristics.clear();
  }

  Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    connectedDevice = null;
    connectingDeviceId.value = null;
    connectionState.value = BluetoothConnectionState.disconnected;
    if (_connectionSubscription != null) {
      try {
        await _connectionSubscription!.cancel();
      } catch (_) {}
      _connectionSubscription = null;
    }
    await _clearCharacteristicSubscriptions();
  }
}

class BluetoothController extends GetxController {
  final MyBluetoothService _bluetoothService = Get.put(MyBluetoothService());

  /// 暴露 connectingDeviceId，供视图层 Obx 订阅以触发列表重建
  RxnString get connectingDeviceId => _bluetoothService.connectingDeviceId;

  List<ScanResult> get devices => _bluetoothService.scanResults;
  RxBool isScanning = false.obs;
  Rx<BluetoothConnectionState> connectionState = BluetoothConnectionState.disconnected.obs;

  /// 设备列表（已连接设备置顶）：保证用户随时能看到当前已连接的设备，
  /// 即便它在扫描间隙因广播间隔未出现在结果中也会保留在首位。
  /// UI 通过 isDeviceConnected() 自动识别该设备为已连接态并展示"已连接"标签。
  List<ScanResult> get sortedDevices {
    final connected = _bluetoothService.connectedDevice;
    if (connected == null) return devices;
    final rest = devices
        .where((r) => r.device.remoteId != connected.remoteId)
        .toList();
    // 已连接设备如果在当前扫描结果里，优先用真实数据（含 RSSI/广播数据）
    int idx = devices.indexWhere((r) => r.device.remoteId == connected.remoteId);
    if (idx >= 0) {
      return [devices[idx], ...rest];
    }
    // 否则构造最小占位项，确保已连接设备始终在列表首位可见
    return [
      ScanResult(
        device: connected,
        advertisementData: AdvertisementData(
          advName: connected.platformName,
          txPowerLevel: 0,
          appearance: 0,
          connectable: true,
          manufacturerData: const {},
          serviceData: const {},
          serviceUuids: const [],
        ),
        rssi: 0,
        timeStamp: DateTime.now(),
      ),
      ...rest,
    ];
  }

  @override
  void onInit() {
    super.onInit();
    // 监听连接状态变化
    connectionState.bindStream(_bluetoothService.connectionState.stream);
  }

  /// 判断给定设备是否为当前已连接设备
  bool isDeviceConnected(BluetoothDevice device) {
    final connected = _bluetoothService.connectedDevice;
    if (connected == null) return false;
    return connected.remoteId == device.remoteId &&
        _bluetoothService.connectionState.value ==
            BluetoothConnectionState.connected;
  }

  /// 判断给定设备是否正在连接中
  bool isDeviceConnecting(BluetoothDevice device) {
    return _bluetoothService.connectingDeviceId.value == device.remoteId.str;
  }

  /// 给定设备的最新信号强度（dBm），未发现返回 null
  int? rssiOf(BluetoothDevice device) {
    for (final r in _bluetoothService.scanResults) {
      if (r.device.remoteId == device.remoteId) return r.rssi;
    }
    return null;
  }

  void startScan() async {
    // 已连接状态下扫描：给个轻提示，让用户知道已连接设备会被保留在列表顶部
    if (_bluetoothService.connectionState.value ==
        BluetoothConnectionState.connected) {
      Get.snackbar(
        '扫描中',
        '当前已连接的设备将保留在列表顶部',
        duration: const Duration(seconds: 2),
      );
    }
    isScanning.value = true;
    await _bluetoothService.startScan();
    // 扫描5秒后自动停止
    Future.delayed(const Duration(seconds: 5), () {
      stopScan();
    });
  }

  void stopScan() {
    _bluetoothService.stopScan();
    isScanning.value = false;
  }

  void connect(BluetoothDevice device) {
    _bluetoothService.connectToDevice(device);
  }

  void disconnect() {
    _bluetoothService.disconnect();
  }
}

class BluetoothView extends StatelessWidget {
  final EEGController eegCtrl = Get.put(EEGController());

  BluetoothView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('实时脑波数据')),
      body: Center(
        child: Obx(() {
          final data = eegCtrl.eegData.value;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSignal(data.poorSignal),
              _buildItem('专注度', data.attention),
              _buildItem('放松度', data.meditation),
              const Divider(),
              _buildItem('Delta', data.delta),
              _buildItem('Theta', data.theta),
              _buildItem('Alpha', data.alpha),
              _buildItem('Beta', data.beta),
              _buildItem('Gamma', data.gamma),
              const Divider(),
              _buildItem('心率', data.heartRate, unit: ' bpm'),
              _buildItem('血氧', data.spO2, unit: ' %'),
              _buildItem('额温', data.foreheadTemp, unit: ' ℃'),
              _buildItem('电池电量', data.battery, unit: ' %'),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(String label, int? value, {String unit = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(
            value == null ? '--' : '$value$unit',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  /// 信号质量：数值 + 档位提示（基于协议 3.3 节建议）
  Widget _buildSignal(int? value) {
    final label = EEGDataModel.signalLabel(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('信号质量', style: TextStyle(fontSize: 18)),
          Text(
            value == null ? '--' : '$value  ($label)',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class BluetoothAdmin extends StatelessWidget {
  final BluetoothController bluetoothCtrl = Get.put(BluetoothController());
  final EEGController eegCtrl = Get.put(EEGController());

  BluetoothAdmin({super.key});

  /// 点击列表项的统一入口：
  /// - 已连接：直接跳 BluetoothView（"查看详情"语义）；断开走 AppBar 右侧"断开当前已连接设备"按钮
  /// - 连接中：toast 提示，不响应
  /// - 未连接：发起连接
  void _onDeviceTap(
      BluetoothDevice device, bool connected, bool connecting) {
    final name =
        device.platformName.isNotEmpty ? device.platformName : '该设备';
    if (connecting) {
      Get.snackbar('正在连接', '$name 正在连接中，请稍候…',
          duration: const Duration(seconds: 2));
      return;
    }
    if (connected) {
      Get.to(() => BluetoothView());
      return;
    }
    bluetoothCtrl.connect(device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙设备'),
        elevation: 1,
        shadowColor: Colors.grey,
        actions: [
          Obx(() {
            final state = bluetoothCtrl.connectionState.value;
            IconData icon;
            Color color;
            if (state == BluetoothConnectionState.connected) {
              icon = Icons.bluetooth_connected;
              color = Colors.green;
            } else {
              icon = Icons.bluetooth_disabled;
              color = Colors.grey;
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: color),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => bluetoothCtrl.isScanning.value
                      ? ElevatedButton(onPressed: bluetoothCtrl.stopScan, child: const Text('正在扫描……点击停止'))
                      : ElevatedButton(
                          onPressed: bluetoothCtrl.startScan,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          child: const Text('扫描可用设备'),
                        ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => bluetoothCtrl.connectionState.value == BluetoothConnectionState.connected
                      ? ElevatedButton(
                          onPressed: bluetoothCtrl.disconnect,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          child: const Text('断开当前已连接设备'),
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // 设备列表
          Expanded(
            child: Obx(() {
              // 强制订阅以下 Rx（让列表在连接/连接中状态变化时重建）：
              // - connectionState：连接状态变化时刷新"已连接"标签
              // - connectingDeviceId：连接中 loading 状态
              // - scanResults：扫描出新设备时刷新列表
              // sortedDevices getter 间接读这些，但 Obx 不会追踪 getter 内的读取，
              // 必须在 builder 函数体内直接 .value 才能注册依赖。
              bluetoothCtrl.connectionState.value;
              bluetoothCtrl.connectingDeviceId.value;
              final list = bluetoothCtrl.sortedDevices;
              if (list.isEmpty) {
                return Center(
                  child: ElevatedButton(onPressed: bluetoothCtrl.startScan, child: const Text('设备列表为空，点击扫描可用设备')),
                );
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final result = list[index];
                  final device = result.device;
                  final connected = bluetoothCtrl.isDeviceConnected(device);
                  final connecting = bluetoothCtrl.isDeviceConnecting(device);
                  return _DeviceListTile(
                    device: device,
                    rssi: result.rssi,
                    connected: connected,
                    connecting: connecting,
                    onTap: () => _onDeviceTap(device, connected, connecting),
                  );
                },
              );
            }),
          ),
          // 实时数据预览（保持简洁，仅做导引）
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Obx(() {
              final data = eegCtrl.eegData.value;
              final signalLabel = EEGDataModel.signalLabel(data.poorSignal);
              return Column(
                children: [
                  Text('专注度: ${data.attention ?? '--'}  放松度: ${data.meditation ?? '--'}', style: const TextStyle(fontSize: 12)),
                  ElevatedButton(onPressed: () => Get.to(() => BluetoothView()), child: const Text('查看详细数据')),
                  Text('佩戴: ${data.poorSignal ?? '--'} ($signalLabel)', style: const TextStyle(fontSize: 12)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// 设备列表项：根据连接状态显示不同 UI
class _DeviceListTile extends StatelessWidget {
  final BluetoothDevice device;
  final int? rssi;
  final bool connected;
  final bool connecting;
  final VoidCallback onTap;

  const _DeviceListTile({
    required this.device,
    required this.rssi,
    required this.connected,
    required this.connecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        device.platformName.isNotEmpty ? device.platformName : '未知设备';

    // 信号强度档位（dBm）：-60 以上极近，-60~-75 普通，-75~-90 偏弱，-90 以下差
    // 注意：未连接的"信号强"用深灰而非绿色，避免与"已连接"的蓝色+绿点撞色
    String rssiLabel = '';
    Color rssiColor = Colors.blueGrey;
    if (rssi != null) {
      final r = rssi!;
      if (r >= -60) {
        rssiLabel = '强';
        rssiColor = Colors.blueGrey.shade700;
      } else if (r >= -75) {
        rssiLabel = '中';
        rssiColor = Colors.blueGrey;
      } else if (r >= -90) {
        rssiLabel = '弱';
        rssiColor = Colors.orange;
      } else {
        rssiLabel = '差';
        rssiColor = Colors.red;
      }
    }

    return ListTile(
      shape: LinearBorder.top(side: BorderSide(color: Colors.grey)),
      leading: _Leading(
          connected: connected, connecting: connecting, rssiColor: rssiColor),
      title: Text(name),
      subtitle: Text(
        rssi == null
            ? device.remoteId.toString()
            : '${device.remoteId.toString()}   ${rssi}dBm ($rssiLabel)',
      ),
      trailing: _Trailing(connected: connected, connecting: connecting),
      onTap: onTap,
    );
  }
}

/// leading 区：根据状态显示不同图标
class _Leading extends StatelessWidget {
  final bool connected;
  final bool connecting;
  final Color rssiColor;
  const _Leading(
      {required this.connected,
      required this.connecting,
      required this.rssiColor});

  @override
  Widget build(BuildContext context) {
    if (connecting) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (connected) {
      return Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.bluetooth, color: Colors.blue, size: 32),
          // 右上角绿点
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }
    return Icon(Icons.bluetooth, color: rssiColor, size: 28);
  }
}

/// trailing 区：根据状态显示：
/// - 已连接：绿色"已连接"标签（圆角胶囊 + 对勾）
/// - 连接中：灰色"连接中…"文字
/// - 未连接：轻量"连接"按钮（圆角 + 蓝色描边），明示这是一个可执行动作，
///   避免与"右箭头"（导航到下一个页面）混淆。
class _Trailing extends StatelessWidget {
  final bool connected;
  final bool connecting;
  const _Trailing({required this.connected, required this.connecting});

  @override
  Widget build(BuildContext context) {
    if (connecting) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('连接中…', style: TextStyle(color: Colors.grey)),
      );
    }
    if (connected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text('已连接', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      );
    }
    // 未连接：圆角轻量按钮，蓝色描边文字"连接"，避免与"导航右箭头"混淆
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bluetooth, color: Colors.blue, size: 14),
          SizedBox(width: 4),
          Text('连接', style: TextStyle(color: Colors.blue, fontSize: 12)),
        ],
      ),
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MyBluetoothService(), permanent: true);
    Get.put(MultimodalHeadbandParser(), permanent: true);
    Get.put(BroadcastService(), permanent: true);
    Get.put(BluetoothController());
    Get.put(EEGController());
  }
}
