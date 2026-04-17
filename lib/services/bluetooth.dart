import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healing_junior/ctrl.dart';
import 'package:healing_junior/services/eeg_data_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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

class TGAMParser extends GetxService {
  // 状态常量
  static const int PARSER_STATE_SYNC = 1; // 同步状态
  static const int PARSER_STATE_SYNC_CHECK = 2; // 同步校验状态
  static const int PARSER_STATE_PAYLOAD_LENGTH = 3; // 有效载荷长度状态
  static const int PARSER_STATE_PAYLOAD = 4; // 有效载荷状态
  static const int PARSER_STATE_CHKSUM = 5; // 校验和状态

  // 扩展码阈值
  static const int MULTI_BYTE_CODE_THRESHOLD = 127;

  // 状态变量
  int _parserStatus = PARSER_STATE_SYNC; // 当前解析状态
  int _payloadLength = 0; // 有效载荷长度
  int _payloadBytesReceived = 0; // 已接收有效载荷字节数
  int _payloadSum = 0; // 有效载荷字节和
  int _checksum = 0; // 校验和
  final List<int> _payload = List.filled(256, 0); // 有效载荷缓冲区
  // 临时存储大包解析出的数据
  final EEGDataModel _tempModel = EEGDataModel();

  void addBytes(List<int> bytes) {
    for (var byte in bytes) {
      _parseByte(byte);
    }
  }

  void _parseByte(int byte) {
    switch (_parserStatus) {
      case PARSER_STATE_SYNC:
        if (byte == 0xAA) _parserStatus = PARSER_STATE_SYNC_CHECK;
        break;

      case PARSER_STATE_SYNC_CHECK:
        if (byte == 0xAA) {
          _parserStatus = PARSER_STATE_PAYLOAD_LENGTH;
        } else {
          _parserStatus = PARSER_STATE_SYNC;
        }
        break;

      case PARSER_STATE_PAYLOAD_LENGTH:
        _payloadLength = byte;
        _payloadBytesReceived = 0;
        _payloadSum = 0;
        _parserStatus = PARSER_STATE_PAYLOAD;
        break;

      case PARSER_STATE_PAYLOAD:
        _payload[_payloadBytesReceived++] = byte;
        _payloadSum += byte;
        if (_payloadBytesReceived >= _payloadLength) {
          _parserStatus = PARSER_STATE_CHKSUM;
        }
        break;

      case PARSER_STATE_CHKSUM:
        _checksum = byte;
        // 校验和计算: (~payloadSum) & 0xFF
        int computed = (~_payloadSum) & 0xFF;
        if (computed == _checksum) {
          // 校验成功，解析payload
          _parsePayload(_payload.sublist(0, _payloadLength));
        }
        _parserStatus = PARSER_STATE_SYNC;
        break;
    }
  }

  void _parsePayload(List<int> data) {
    int i = 0;
    while (i < data.length) {
      int code = data[i];
      int valueBytesLength = 1;

      // 处理扩展码 (0x55 后跟多字节)
      if (code == 0x55) {
        // 扩展码，后面跟的字节表示实际code，且可能是多字节
        // 简化处理：实际项目中可能需要递归解析，但TGAM文档未提及扩展码使用，暂忽略
        i++;
        continue;
      }

      // 判断是否为多字节值 (code > 127 表示后面的数据长度为2字节)
      if (code > MULTI_BYTE_CODE_THRESHOLD) {
        valueBytesLength = 2;
      }

      // 检查数据是否足够
      if (i + valueBytesLength >= data.length) break;

      // 提取值
      int value;
      if (valueBytesLength == 1) {
        value = data[i + 1] & 0xFF;
      } else {
        // 两字节值: 高字节在前，低字节在后
        value = (data[i + 1] << 8) | (data[i + 2] & 0xFF);
      }

      // 根据code处理
      switch (code) {
        case 0x02: // 信号质量
          _tempModel.poorSignal = value;
          break;
        case 0x04: // 专注度
          _tempModel.attention = value;
          break;
        case 0x05: // 放松度
          _tempModel.meditation = value;
          break;
        case 0x80: // 原始数据 (两字节)
          // 原始数据以小包形式出现，此处value为两字节拼接结果，需转换为有符号16位
          int raw = value;
          if (raw >= 32768) raw -= 65536;
          _tempModel.rawData = raw;
          // 单独更新原始数据，不等待大包
          _publishData(onlyRaw: true);
          break;
        case 0x83:
          int length = (i + 1 < data.length) ? data[i + 1] : 0;
          _parseEEGPower(data, i);
          i += 2 + length;
          continue;
      }

      i += 1 + valueBytesLength;
    }
    _publishData();
  }

  void _parseEEGPower(List<int> data, int startIndex) {
    if (startIndex + 2 > data.length) return;
    int length = data[startIndex + 1];
    if (startIndex + 2 + length > data.length) return;
    if (length != 24) return; // 按 TGAM 协议：EEG 功率长度应为 24
    for (int b = 0; b < 8; b++) {
      int byteHigh = data[startIndex + 2 + b * 3];
      int byteMid = data[startIndex + 2 + b * 3 + 1];
      int byteLow = data[startIndex + 2 + b * 3 + 2];
      int value = (byteHigh << 16) | (byteMid << 8) | byteLow;
      switch (b) {
        case 0:
          _tempModel.delta = value;
          break;
        case 1:
          _tempModel.theta = value;
          break;
        case 2:
          _tempModel.lowAlpha = value;
          break;
        case 3:
          _tempModel.highAlpha = value;
          break;
        case 4:
          _tempModel.lowBeta = value;
          break;
        case 5:
          _tempModel.highBeta = value;
          break;
        case 6:
          _tempModel.lowGamma = value;
          break;
        case 7:
          _tempModel.midGamma = value;
          break;
      }
    }
  }

  void _publishData({bool onlyRaw = false}) {
    // 复制当前数据到新对象，避免后续修改影响已发布的数据
    final eegData = _tempModel.copy();

    // 更新EEGController
    Get.find<EEGController>().updateEEGData(eegData);

    // 广播（第二阶段）
    //Get.find<BroadcastService>().broadcastData(eegData);

    if (onlyRaw) {
      // 如果只更新了原始数据，不清空其他字段，因为大包还会来
      // 但原始数据是瞬时的，可以保留
    } else {
      // 大包解析完后，不清空，等待下一次大包覆盖
      // 注意信号质量等可能会单独出现，不需要清空
    }
  }
}

class EEGController extends GetxController {
  final eegData = EEGDataModel().obs;
  final tempCount = 0.obs;
  final tempDataAtt = <double>[].obs;
  final tempDataMed = <double>[].obs;
  final tempDataDelta = <double>[].obs;
  final tempDataTheta = <double>[].obs;
  final tempDataAlpha = <double>[].obs;
  final tempDataBeta = <double>[].obs;
  final tempDataGamma = <double>[].obs;
  final MyCtrl myCtrl = Get.put(MyCtrl());
  static const LOWER = 0;
  // 每秒执行一次的定时器
  Timer? _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void onClose() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    super.onClose();
  }

  void _onTick() {
    // 每秒执行的任务（可按需修改）
    if (tempCount.value > 1) {
      double att = tempDataAtt.reduce((a, b) => a > b ? a : b);
      double med = tempDataMed.reduce((a, b) => a > b ? a : b);
      double delta = tempDataDelta.reduce((a, b) => a > b ? a : b);
      double theta = tempDataTheta.reduce((a, b) => a > b ? a : b);
      double alpha = tempDataAlpha.reduce((a, b) => a > b ? a : b);
      double beta = tempDataBeta.reduce((a, b) => a > b ? a : b);
      double gamma = tempDataGamma.reduce((a, b) => a > b ? a : b);
      myCtrl.pushData([att, med, delta, theta, alpha, beta, gamma]);
      tempDataAtt.clear();
      tempDataMed.clear();
      tempDataDelta.clear();
      tempDataTheta.clear();
      tempDataAlpha.clear();
      tempDataBeta.clear();
      tempDataGamma.clear();

      tempCount.value = 0;
    }
    debugPrint('EEGController tick: ${DateTime.now()}');
  }

  void updateEEGData(EEGDataModel data) {
    eegData.value = data;
    if (tempCount.value < 256) {
      double att = eegData.value.attention?.toDouble() ?? 0.0;
      double med = eegData.value.meditation?.toDouble() ?? 0.0;
      double delta = eegData.value.delta?.toDouble() ?? 0.0;
      double theta = eegData.value.theta?.toDouble() ?? 0.0;
      double lowAlpha = eegData.value.lowAlpha?.toDouble() ?? 0.0;
      double highAlpha = eegData.value.highAlpha?.toDouble() ?? 0.0;
      double alpha = lowAlpha + highAlpha;
      double lowBeta = eegData.value.lowBeta?.toDouble() ?? 0.0;
      double highBeta = eegData.value.highBeta?.toDouble() ?? 0.0;
      double beta = lowBeta + highBeta;
      double lowGamma = eegData.value.lowGamma?.toDouble() ?? 0.0;
      double midGamma = eegData.value.midGamma?.toDouble() ?? 0.0;
      double gamma = lowGamma + midGamma;
      if (att > LOWER && med > LOWER && delta > LOWER && theta > LOWER && alpha > LOWER && beta > LOWER && gamma > LOWER) {
        tempDataAtt.add(att);
        tempDataMed.add(med);
        tempDataDelta.add(delta);
        tempDataTheta.add(theta);
        tempDataAlpha.add(alpha);
        tempDataBeta.add(beta);
        tempDataGamma.add(gamma);

        tempCount.value++;
      }
    }
  }
}

class MyBluetoothService extends GetxService {
  static const String TARGET_DEVICE_NAME_PREFIX = 'HR-'; // 目标设备名称前缀

  final scanResults = <ScanResult>[].obs;
  final connectionState = BluetoothConnectionState.disconnected.obs;
  BluetoothDevice? connectedDevice;

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

    scanResults.clear();
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
    connectedDevice = device;

    try {
      await device.connect(license: License.free, autoConnect: false);

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
              Get.find<TGAMParser>().addBytes(value);
            });
            _charSubscriptions.add(sub);
            _notifyingCharacteristics.add(characteristic);
          }
        }
      }
    } catch (e) {
      Get.snackbar('连接失败', e.toString());
      connectionState.value = BluetoothConnectionState.disconnected;
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

  List<ScanResult> get devices => _bluetoothService.scanResults;
  RxBool isScanning = false.obs;
  Rx<BluetoothConnectionState> connectionState = BluetoothConnectionState.disconnected.obs;

  @override
  void onInit() {
    super.onInit();
    // 监听连接状态变化
    connectionState.bindStream(_bluetoothService.connectionState.stream);
  }

  void startScan() async {
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
              _buildItem('信号质量', data.poorSignal),
              _buildItem('专注度', data.attention),
              _buildItem('放松度', data.meditation),
              _buildItem('原始数据', data.rawData),
              const Divider(),
              _buildItem('Delta', data.delta),
              _buildItem('Theta', data.theta),
              _buildItem('低Alpha', data.lowAlpha),
              _buildItem('高Alpha', data.highAlpha),
              _buildItem('低Beta', data.lowBeta),
              _buildItem('高Beta', data.highBeta),
              _buildItem('低Gamma', data.lowGamma),
              _buildItem('中Gamma', data.midGamma),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(String label, int? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value?.toString() ?? '--', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class BluetoothAdmin extends StatelessWidget {
  final BluetoothController bluetoothCtrl = Get.put(BluetoothController());
  final EEGController eegCtrl = Get.put(EEGController());

  BluetoothAdmin({super.key});

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
              if (bluetoothCtrl.devices.isEmpty) {
                return Center(
                  child: ElevatedButton(onPressed: bluetoothCtrl.startScan, child: const Text('设备列表为空，点击扫描可用设备')),
                );
              }
              return ListView.builder(
                itemCount: bluetoothCtrl.devices.length,
                itemBuilder: (context, index) {
                  final result = bluetoothCtrl.devices[index];
                  final device = result.device;
                  return ListTile(
                    shape: LinearBorder.top(side: BorderSide(color: Colors.grey)),
                    title: Text(device.platformName.isNotEmpty ? device.platformName : '未知设备'),
                    subtitle: Text(device.remoteId.toString()),
                    leading: Icon(Icons.bluetooth),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () => bluetoothCtrl.connect(device),
                  );
                },
              );
            }),
          ),
          // 实时数据预览
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
                  offset: const Offset(0, 1), // 阴影方向
                ),
              ],
            ),
            child: Obx(() {
              final data = eegCtrl.eegData.value;
              return Column(
                children: [
                  Text('专注度: ${data.attention ?? '--'} 放松度: ${data.meditation ?? '--'}', style: const TextStyle(fontSize: 12)),
                  ElevatedButton(onPressed: () => Get.to(() => BluetoothView()), child: const Text('查看详细数据')),
                  Text('佩戴状态码: ${data.poorSignal ?? '--'}', style: const TextStyle(fontSize: 12)),
                  Text('0正常、0~200信号质量异常、200未佩戴', style: const TextStyle(fontSize: 10)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MyBluetoothService(), permanent: true);
    Get.put(TGAMParser(), permanent: true);
    Get.put(BroadcastService(), permanent: true);
    Get.put(BluetoothController());
    Get.put(EEGController());
  }
}
