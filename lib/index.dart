import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:healing_junior/apps/card_oh.dart';
import 'package:healing_junior/ctrl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:printing/printing.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:healing_junior/apps/customer.dart';
import 'package:healing_junior/apps/employee.dart';
import 'package:healing_junior/apps/face.dart';
import 'package:healing_junior/apps/setting.dart';
import 'package:healing_junior/view.dart';

// ==================== 原有代码（保持不变）====================

class IndexView extends StatelessWidget {
  const IndexView({super.key});
  @override
  Widget build(BuildContext context) {
    // 初始化 AIDialogCtrl（如果尚未初始化）
    Get.put(AIDialogCtrl());
    final controller = Get.put(IndexCtrl());
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.index.value,
            children: [
              FaceView(),
              CardohView(),
              MyView(),
              SettingView(),
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            selectedFontSize: 16,
            unselectedFontSize: 16,
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey,
            currentIndex: controller.index.value,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: controller.updateIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.child_care_rounded), label: '欢迎'),
              BottomNavigationBarItem(icon: Icon(Icons.style), label: 'OH卡'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_graph_rounded), label: '脑波'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
            ],
          )),
      floatingActionButton: _buildFAB(context),
    );
  }

  /// 构建浮动按钮：录音状态动态显示
  Widget _buildFAB(BuildContext context) {
    return Obx(() {
      final aiCtrl = Get.find<AIDialogCtrl>();
      final isRecording = aiCtrl.isRecording.value;

      return FloatingActionButton(
        onPressed: () => _showAIDialog(context),
        backgroundColor: isRecording ? Colors.red : null,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isRecording
              ? const _RecordingIndicator() // 录音中：动态图标
              : const Icon(Icons.wechat_rounded, key: ValueKey('chat')),
        ),
      );
    });
  }

  void _showAIDialog(BuildContext context) {
    Get.bottomSheet(
      const AIDialogSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      persistent: true,
    );
  }
}

/// 录音中动态指示器（红色脉冲动画）
class _RecordingIndicator extends StatefulWidget {
  const _RecordingIndicator();

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: const Icon(Icons.mic, key: ValueKey('recording'), color: Colors.white),
        );
      },
    );
  }
}

class IndexCtrl extends GetxController {
  final index = 0.obs;
  void updateIndex(int value) {
    index.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    Get.put(AIDialogCtrl());
  }

  /// 注入情绪事件（供脑电波监测模块调用）
  /// 每隔16秒脑电波模块调用一次
  void injectEmotion(String emotion) {
    try {
      final aiCtrl = Get.find<AIDialogCtrl>();
      aiCtrl.injectEmotion(emotion);
    } catch (_) {}
  }
}

// ==================== 火山引擎ASR WebSocket封装 ====================
/// 火山引擎大模型流式语音识别服务
/// 文档: https://www.volcengine.com/docs/6561/1354869
/// 特点: 直接连续发送音频流，无需客户端VAD，服务器只在结果变化时返回
/// 健壮性: 录音/识别中断时自动重连恢复
class VolcASRService {
  static const String _wsUrl = 'wss://openspeech.bytedance.com/api/v3/sauc/bigmodel_async';
  static const String _apiKey = '549a8a0a-3b6a-4a17-a1bc-8c0aa7ac0808';

  WebSocket? _ws;
  AudioRecorder? _recorder;
  StreamSubscription? _wsSubscription;
  StreamSubscription? _audioSubscription;

  final _resultController = StreamController<ASRResult>.broadcast();
  Stream<ASRResult> get resultStream => _resultController.stream;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  void Function(String state)? onStateChange;
  void Function(String error)? onError;
  void Function()? onDisconnected;
  void Function()? onRecovery; // 恢复成功回调

  String? _requestId;

  Future<void> startRecording() async {
    if (_isRecording) return;

    _requestId = '${DateTime.now().millisecondsSinceEpoch}';
    _isRecording = true;

    try {
      _recorder = AudioRecorder();
      final hasPermission = await _recorder!.hasPermission();
      if (!hasPermission) {
        _isRecording = false;
        onError?.call('麦克风权限被拒绝');
        _recorder?.dispose();
        _recorder = null;
        return;
      }

      onStateChange?.call('connecting');
      await _connectWebSocket();

      final audioStream = await _recorder!.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      _isRecording = true;
      onStateChange?.call('recording');

      // 直接连续发送所有音频流（无需VAD判断）
      _audioSubscription = audioStream.listen(
        (data) {
          if (!_isRecording || _ws == null) return;
          if (_ws!.readyState != WebSocket.open) return;
          try {
            _ws!.add(_buildAudioPacket(data));
          } catch (_) {}
        },
        onError: (e) => _handleAudioError('音频流错误: $e'),
        onDone: () {
          if (_isRecording) _handleAudioError('音频流意外结束');
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isRecording = false;
      onError?.call('启动失败: $e');
      onStateChange?.call('error');
    }
  }

  /// 处理音频错误，尝试自动恢复
  void _handleAudioError(String error) {
    _cleanup();
    if (_isRecording) _attemptRecovery();
  }

  /// 自动恢复录音和识别
  Future<void> _attemptRecovery() async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries && _isRecording) {
      retryCount++;

      try {
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
        await _connectWebSocket();

        if (_recorder != null) {
          final audioStream = await _recorder!.startStream(
            const RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 16000,
              numChannels: 1,
            ),
          );

          _audioSubscription = audioStream.listen(
            (data) {
              if (!_isRecording || _ws == null) return;
              if (_ws!.readyState != WebSocket.open) return;
              try {
                _ws!.add(_buildAudioPacket(data));
              } catch (_) {}
            },
            onError: (e) => _handleAudioError('音频流错误: $e'),
            cancelOnError: false,
          );

          onRecovery?.call();
          return;
        }
      } catch (_) {}
    }

    if (_isRecording) {
      _isRecording = false;
      onError?.call('录音识别中断，已自动重连失败');
      onStateChange?.call('error');
      onDisconnected?.call();
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;
    _isRecording = false;
    _cleanup();
    onStateChange?.call('idle');
  }

  void _cleanup() {
    _audioSubscription?.cancel();
    _audioSubscription = null;
    _wsSubscription?.cancel();
    _wsSubscription = null;
    if (_ws != null) {
      try {
        _ws!.close();
      } catch (_) {}
      _ws = null;
    }
  }

  Future<void> _connectWebSocket() async {
    final headers = {
      'X-Api-Key': _apiKey,
      'X-Api-Resource-Id': 'volc.seedasr.sauc.duration',
      'X-Api-Request-Id': _requestId!,
      'X-Api-Sequence': '-1',
    };

    try {
      _ws = await WebSocket.connect(_wsUrl, headers: headers);
    } catch (e) {
      onError?.call('WebSocket连接失败: $e');
      onDisconnected?.call();
      return;
    }

    final config = {
      'app': {
        'cluster': 'volcengine_streaming_common',
      },
      'user': {'uid': 'user_$_requestId'},
      'audio': {'format': 'pcm', 'rate': 16000, 'bits': 16, 'channel': 1, 'codec': 'raw'},
      'request': {
        'reqid': _requestId,
        'sequence': -1,
        'language': 'zh-CN',
        'enable_partial': true,
        'enable_punc': true,
        'show_utterances': true,
        'enable_nonstream': true, // bigmodel_async 必需
        'enable_speaker_info': true,
        'ssd_version': '200',
      },
    };

    // 配置消息用 binary frame 发送
    _ws!.add(_buildBinaryPacket(utf8.encode(jsonEncode(config))));

    _wsSubscription = _ws!.listen(
      (message) => _handleMessage(message),
      onError: (e) {
        debugPrint('ASR WebSocket error: $e');
        _cleanup();
        if (_isRecording) _attemptRecovery();
      },
      onDone: () {
        debugPrint('ASR WebSocket done');
        _cleanup();
        if (_isRecording) onDisconnected?.call();
      },
    );
  }

  /// 手动重连
  Future<bool> attemptReconnect() async {
    if (!_isRecording) return false;

    try {
      _cleanup();
      await _connectWebSocket();
      if (_recorder != null) {
        final audioStream = await _recorder!.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );
        _audioSubscription = audioStream.listen(
          (data) {
            if (!_isRecording || _ws == null) return;
            if (_ws!.readyState != WebSocket.open) return;
            try {
              _ws!.add(_buildAudioPacket(data));
            } catch (_) {}
          },
          onError: (e) => _handleAudioError('音频流错误: $e'),
          cancelOnError: false,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Uint8List _buildBinaryPacket(List<int> payload) {
    // 协议格式：4字节header + 4字节payload_size + payload
    // header: [protocol_version(4)][header_size(4)][message_type(4)][flags(4)][serialization(4)][compression(4)][reserved(8)]
    // full client request: message_type=1 (0b0001), serialization=1 (JSON)
    final header = ByteData(4);
    header.setUint8(0, 0x11); // protocol_version=1, header_size=1
    header.setUint8(1, 0x10); // message_type=1 (full client request), flags=0
    header.setUint8(2, 0x10); // serialization=1 (JSON), compression=0
    header.setUint8(3, 0x00); // reserved
    final payloadSize = ByteData(4)..setUint32(0, payload.length, Endian.big);
    final packet = Uint8List(8 + payload.length);
    packet.setRange(0, 4, header.buffer.asUint8List());
    packet.setRange(4, 8, payloadSize.buffer.asUint8List());
    packet.setRange(8, 8 + payload.length, payload);
    return packet;
  }

  Uint8List _buildAudioPacket(List<int> audioData) {
    // audio only request: message_type=2 (0b0010), serialization=0 (无序列化)
    final header = ByteData(4);
    header.setUint8(0, 0x11); // protocol_version=1, header_size=1
    header.setUint8(1, 0x20); // message_type=2 (audio only request), flags=0
    header.setUint8(2, 0x00); // serialization=0 (无序列化), compression=0
    header.setUint8(3, 0x00); // reserved
    final payloadSize = ByteData(4)..setUint32(0, audioData.length, Endian.big);
    final packet = Uint8List(8 + audioData.length);
    packet.setRange(0, 4, header.buffer.asUint8List());
    packet.setRange(4, 8, payloadSize.buffer.asUint8List());
    packet.setRange(8, 8 + audioData.length, audioData);
    return packet;
  }

  void _handleMessage(dynamic message) {
    // 停止后不再处理消息
    if (!_isRecording) return;

    try {
      if (message is List<int>) {
        int jsonStart = -1;
        for (int i = 0; i < message.length; i++) {
          if (message[i] == 123) {
            jsonStart = i;
            break;
          }
        }
        if (jsonStart >= 0) {
          _parseJsonText(utf8.decode(message.sublist(jsonStart)));
        }
      } else if (message is String) {
        _parseJsonText(message);
      }
    } catch (_) {}
  }

  void _parseJsonText(String text) {
    if (text.trim().isEmpty) return;
    try {
      final data = jsonDecode(text);
      final code = data['code'];
      if (code != null && code != 0) {
        onError?.call('ASR错误 $code: ${data['message'] ?? '未知错误'}');
        return;
      }
      final result = data['result'];
      if (result == null) return;

      final utterances = result['utterances'] as List?;
      if (utterances == null || utterances.isEmpty) return;

      final speakerTexts = <MapEntry<int, String>>[];
      for (final utt in utterances) {
        // 获取 text
        final uttText = utt['text'];
        if (uttText == null || uttText.toString().trim().isEmpty) continue;

        // 获取 speaker_id（从 additions 里面，支持 int 或 String 类型）
        int speakerId = 0;
        final additions = utt['additions'];
        if (additions != null) {
          final sid = additions['speaker_id'];
          if (sid is int) {
            speakerId = sid;
          } else if (sid is String) {
            speakerId = int.tryParse(sid) ?? 0;
          }
        }

        speakerTexts.add(MapEntry(speakerId, uttText.toString().trim()));
      }
      if (speakerTexts.isEmpty) return;

      final combinedText = speakerTexts.map((e) => e.value).join(' ');
      _resultController.add(ASRResult(
        text: combinedText,
        speakerTexts: speakerTexts,
        timestamp: DateTime.now(),
      ));
    } catch (_) {}
  }

  void dispose() {
    stopRecording();
    _resultController.close();
  }
}

class ASRResult {
  final String text; // 所有speaker的完整累积文本（用于左侧显示）
  final List<MapEntry<int, String>> speakerTexts; // 每个speaker的累积文本（用于分析）
  final DateTime timestamp;

  ASRResult({
    required this.text,
    required this.speakerTexts,
    required this.timestamp,
  });
}

/// 情绪事件
class _EmotionEvent {
  final DateTime timestamp;
  final String emotion;
  _EmotionEvent({required this.timestamp, required this.emotion});
}

/// 混合事件（用于生成混合文本）
class _MixedEvent {
  final DateTime timestamp;
  final String type; // 'dialog' or 'emotion'
  final int? speakerId;
  final String text;
  _MixedEvent({required this.timestamp, required this.type, this.speakerId, required this.text});
}

// ==================== 说话人角色 ====================

enum SpeakerRole { therapist, client, unknown }

class SpeakerRoleInfo {
  final int speakerId;
  final String label;
  int questionCount = 0;
  int answerCount = 0;
  SpeakerRole inferredRole = SpeakerRole.unknown;

  SpeakerRoleInfo({required this.speakerId, required this.label});

  double get questionRatio => (questionCount + answerCount) > 0 ? questionCount / (questionCount + answerCount) : 0.0;
}

/// 报告文件信息
class ReportInfo {
  final String fileName; // 文件名（不含路径）
  final String title; // 显示标题
  final DateTime createdAt;

  ReportInfo({
    required this.fileName,
    required this.title,
    required this.createdAt,
  });
}

// ==================== AI对话控制器 ====================

enum AIDialogState { idle, connecting, recording, error }

/// 处理后的对话条目（用于右侧对话显示）
class ProcessedDialogEntry {
  final String speakerLabel;
  final SpeakerRole? role; // null表示角色尚未明确
  final String text;
  final bool isHint;
  final int rawIndex; // 对应原始记录的索引

  ProcessedDialogEntry({
    required this.speakerLabel,
    this.role,
    required this.text,
    this.isHint = false,
    this.rawIndex = -1,
  });
}

// ==================== Coze 提示问题生成 ====================

/// Coze提示问题生成服务
///
/// Coze Agent 提示词设计：
/// - 仅输出一个问题字符串（≤30字）
/// - 四类问题：感受探索、深入挖掘、关联链接、行动引导
/// - 语气温和，避免"为什么""应该"
/// - 基于OH卡疗愈主题
class CozeHintService {
  static const String _botId = '7646075412124352548';
  static const String _apiBase = 'https://api.coze.cn/v3/chat';

  /// 生成提示问题
  /// [conversation] 对话上下文，格式：【来访者/疗愈师】：内容
  /// 返回：一个问题字符串（约20字），或空字符串
  static Future<String> generateHint({
    required String conversation,
  }) async {
    if (conversation.isEmpty) {
      return '';
    }

    // 获取bearer token
    final bearer = await _getBearerToken();
    if (bearer.isEmpty) {
      return '';
    }

    try {
      final client = http.Client();
      final request = http.Request('POST', Uri.parse(_apiBase));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearer',
      });
      request.body = jsonEncode({
        'bot_id': _botId,
        'user_id': '${DateTime.now().millisecondsSinceEpoch}',
        'stream': true,
        'additional_messages': [
          {'role': 'user', 'content': conversation, 'content_type': 'text', 'type': 'question'}
        ],
      });

      final response = await client.send(request);

      String buffer = '';
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
      }

      // 解析SSE响应，直接返回纯文本
      return _parseResponse(buffer);
    } catch (e) {
      return '';
    }
  }

  /// 解析SSE响应，Coze流式响应格式
  /// 格式: event: xxx\ndata: {json}\n\n
  /// 解析SSE响应，Coze流式响应格式
  /// 格式: event::xxx\ndata: {json}\n\n
  /// 注意：Coze API 的 event 字段格式为 "event::conversation.message.completed"（双冒号）
  static String _parseResponse(String response) {
    try {
      // 按事件块分割（两个换行符分隔）
      final eventBlocks = response.split('\n\n');

      for (final block in eventBlocks) {
        if (block.isEmpty) continue;

        final lines = block.split('\n');
        String? eventName;
        String? jsonStr;

        for (final line in lines) {
          if (line.startsWith('event:')) {
            // 提取事件名称并去掉前缀冒号
            // "event::conversation.message.completed" → "conversation.message.completed"
            eventName = line.substring(5).replaceFirst(':', '').trim();
          } else if (line.startsWith('data:')) {
            jsonStr = line.substring(5).trim();
          }
        }

        // 检查是否是消息完成事件
        if (eventName == 'conversation.message.completed' && jsonStr != null && jsonStr.isNotEmpty) {
          final data = jsonDecode(jsonStr);

          // content 字段可能是字符串，也可能是对象数组
          if (data['content'] != null) {
            final content = data['content'];
            if (content is String) {
              return content.trim();
            } else if (content is List && content.isNotEmpty) {
              // 如果是数组，取第一个元素的 text 字段
              final firstItem = content[0];
              if (firstItem is Map && firstItem['text'] != null) {
                return firstItem['text'].toString().trim();
              }
            }
          }
        }
      }
    } catch (_) {}
    return '';
  }

  static Future<String> _getBearerToken() async {
    try {
      final employeeCtrl = Get.find<EmployeeCtrl>();
      if (employeeCtrl.phone.value.isEmpty) {
        return '';
      }
      final token = await employeeCtrl.pay(0.1);
      return token;
    } catch (e) {
      return '';
    }
  }
}

// ==================== Coze 疗愈报告生成 ====================

/// Coze疗愈报告生成服务
///
/// 输入：
/// - 疗愈师姓名、来访者姓名、对话日期
/// - 原始对话记录
/// 输出：
/// - 纯Markdown格式报告，包含：对话摘要、关键洞察、疗愈建议、下次对话参考
class CozeReportService {
  static const String _botId = '7646317166761066542';
  static const String _apiBase = 'https://api.coze.cn/v3/chat';

  /// 生成疗愈报告
  /// [therapistName] 疗愈师姓名
  /// [clientName] 来访者姓名
  /// [dialogDate] 对话日期
  /// [dialogContent] 原始对话记录
  /// 返回：Markdown格式报告内容，或空字符串
  static Future<String> generateReport({
    required String therapistName,
    required String clientName,
    required DateTime dialogDate,
    required String dialogContent,
  }) async {
    if (dialogContent.isEmpty) {
      return '';
    }

    // 构建输入文本
    final prompt = _buildPrompt(
      therapistName: therapistName,
      clientName: clientName,
      dialogDate: dialogDate,
      dialogContent: dialogContent,
    );

    // 获取bearer token
    final bearer = await _getBearerToken();
    if (bearer.isEmpty) {
      return '';
    }

    try {
      final client = http.Client();
      final request = http.Request('POST', Uri.parse(_apiBase));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearer',
      });
      request.body = jsonEncode({
        'bot_id': _botId,
        'user_id': '${DateTime.now().millisecondsSinceEpoch}',
        'stream': true,
        'additional_messages': [
          {'role': 'user', 'content': prompt, 'content_type': 'text', 'type': 'question'}
        ],
      });

      final response = await client.send(request);
      String buffer = '';
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
      }

      // 解析SSE响应，直接返回Markdown内容
      return _parseResponse(buffer);
    } catch (e) {
      return '';
    }
  }

  static String _buildPrompt({
    required String therapistName,
    required String clientName,
    required DateTime dialogDate,
    required String dialogContent,
  }) {
    return '''疗愈师姓名：$therapistName
对话日期：${dialogDate.year}-${dialogDate.month.toString().padLeft(2, '0')}-${dialogDate.day.toString().padLeft(2, '0')}
来访者姓名：$clientName

对话内容：
$dialogContent''';
  }

  /// 解析SSE响应，返回Markdown内容
  static String _parseResponse(String response) {
    try {
      // 按事件分割，每个事件格式为: event: xxx\ndata: {json}\n\n
      final eventBlocks = response.split('\n\n');
      for (final block in eventBlocks) {
        if (block.isEmpty) continue;

        final lines = block.split('\n');
        String? eventName;
        String? jsonStr;

        for (final line in lines) {
          if (line.startsWith('event:')) {
            // Coze格式是双冒号："event::conversation.message.completed"
            // 需要去掉前缀冒号
            eventName = line.substring(5).replaceFirst(':', '').trim();
          } else if (line.startsWith('data:')) {
            jsonStr = line.substring(5).trim();
          }
        }

        // 检查是否是消息完成事件
        if (eventName == 'conversation.message.completed' && jsonStr != null && jsonStr.isNotEmpty) {
          final data = jsonDecode(jsonStr);
          // content 字段可能是字符串，也可能是对象数组
          if (data['content'] != null) {
            final content = data['content'];
            if (content is String) {
              return content.trim();
            } else if (content is List && content.isNotEmpty) {
              // 如果是数组，取第一个元素的 text 字段
              final firstItem = content[0];
              if (firstItem is Map && firstItem['text'] != null) {
                return firstItem['text'].toString().trim();
              }
            }
          }
        }
      }
    } catch (_) {}
    return '';
  }

  static Future<String> _getBearerToken() async {
    try {
      final employeeCtrl = Get.find<EmployeeCtrl>();
      if (employeeCtrl.phone.value.isEmpty) {
        return '';
      }
      final token = await employeeCtrl.pay(1);
      return token;
    } catch (e) {
      return '';
    }
  }
}

class AIDialogCtrl extends GetxController {
  final _asrService = VolcASRService();

  final state = AIDialogState.idle.obs;
  final isRecording = false.obs;
  final errorMessage = ''.obs;

  // ========== 左侧：当前完整全文（覆盖显示，不是追加条目）==========
  final currentFullText = ''.obs;
  String _lastDisplayText = ''; // 上次显示的全文，用于去重

  // ========== 每个speaker的累积文本（用于分析和整理）==========
  final Map<int, String> _speakerTexts = {};

  // ========== 情绪事件（用于混合显示）==========
  final List<_EmotionEvent> _emotionEvents = [];

  /// 注入情绪事件（供脑电波监测模块调用）
  /// 注意：此方法只存储情绪事件，不影响语音识别的实时显示
  void injectEmotion(String emotion) {
    if (!_isSessionActive) return;
    _emotionEvents.add(_EmotionEvent(
      timestamp: DateTime.now(),
      emotion: emotion,
    ));
    // 不更新 currentFullText，保持原有语音识别显示不变
    // 情绪内容只在报告生成时混入
  }

  // ========== 右侧：对话区域 ==========
  final processedDialogs = <ProcessedDialogEntry>[].obs;

  // ========== 提示问题 ==========
  final hints = <String>[].obs;
  final Set<String> _shownHints = {};

  // ========== 报告相关 ==========
  final reportList = <ReportInfo>[].obs; // 已存储的报告列表
  final isGeneratingReport = false.obs; // 是否正在生成报告
  final _showReportButton = false.obs; // 是否显示"生成报告"按钮
  final cardohReportMarkdown = "".obs;

  // ========== 说话人分析 ==========
  final Map<int, SpeakerRoleInfo> _speakerInfos = {};
  final Map<int, int> _speakerLabelMap = {};
  int _nextLabelIndex = 0;

  // ========== 定时器 ==========
  Timer? _reanalysisTimer;
  Timer? _hintTimer;

  @override
  void onInit() {
    super.onInit();
    _initASRService();
    _loadReportList();
  }

  @override
  void onClose() {
    stopRecording();
    _asrService.dispose();
    _reanalysisTimer?.cancel();
    _hintTimer?.cancel();
    super.onClose();
  }

  void _initASRService() {
    _asrService.onStateChange = (newState) {
      switch (newState) {
        case 'recording':
          state.value = AIDialogState.recording;
          isRecording.value = true;
          errorMessage.value = '';
          break;
        case 'idle':
          state.value = AIDialogState.idle;
          isRecording.value = false;
          break;
        case 'error':
          state.value = AIDialogState.error;
          isRecording.value = false;
          break;
        default:
          break;
      }
    };

    _asrService.onError = (error) {
      errorMessage.value = error;
      state.value = AIDialogState.error;
      isRecording.value = false;
    };

    // 连接断开时尝试重连
    _asrService.onDisconnected = () {
      if (_isSessionActive && !_isReconnecting) {
        _attemptReconnect();
      }
    };

    _asrService.resultStream.listen(_onASRResult);
  }

  bool _isSessionActive = false;
  bool _isReconnecting = false;
  static const int _maxReconnectAttempts = 3;
  int _reconnectAttempts = 0;

  void _attemptReconnect() async {
    _isReconnecting = true;
    _reconnectAttempts = 0;

    while (_reconnectAttempts < _maxReconnectAttempts && _isSessionActive) {
      _reconnectAttempts++;
      errorMessage.value = '连接断开，第 $_reconnectAttempts 次重连...';

      final success = await _asrService.attemptReconnect();
      if (success) {
        _isReconnecting = false;
        errorMessage.value = '';
        return;
      }

      // 重连失败，等待1秒后重试
      if (_reconnectAttempts < _maxReconnectAttempts) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    _isReconnecting = false;
    _isSessionActive = false;
    errorMessage.value = '连接中断，请重新开始';
    state.value = AIDialogState.error;
  }

  void _onASRResult(ASRResult result) {
    final text = result.text.trim();
    if (text.isEmpty) return;

    // 去重：比较本次全文与上次显示的全文
    if (text == _lastDisplayText) {
      return;
    }
    _lastDisplayText = text;

    // 更新每个speaker的累积文本
    for (final entry in result.speakerTexts) {
      final speakerId = entry.key;
      final uttText = entry.value;
      if (uttText.isNotEmpty) {
        _speakerTexts[speakerId] = uttText;
        _getOrAssignLabel(speakerId);
      }
    }

    // 保持原有显示方式：拼接带说话人标记的完整文本
    // speaker_id=0 → 某人, 1 → A, 2 → B, 3 → C...
    final markedText = result.speakerTexts.map((e) {
      String label;
      if (e.key == 0) {
        label = '某';
      } else {
        label = String.fromCharCode(65 + e.key - 1); // 1→A, 2→B, 3→C...
      }
      return '【$label说】${e.value}';
    }).join('\n');
    currentFullText.value = markedText;

    // 立即重新分析（因为全文已更新）
    _reAnalyze();
  }

  /// 生成混合文本（对话 + 情绪，用于报告和提示问题）
  String _generateMixedText() {
    // 收集所有事件
    final allEvents = <_MixedEvent>[];

    // 添加对话事件（使用当前 _speakerTexts）
    final now = DateTime.now();
    int idx = 0;
    for (final entry in _speakerTexts.entries) {
      allEvents.add(_MixedEvent(
        timestamp: now.subtract(Duration(seconds: _speakerTexts.length - idx)),
        type: 'dialog',
        speakerId: entry.key,
        text: entry.value,
      ));
      idx++;
    }

    // 添加情绪事件
    for (final e in _emotionEvents) {
      allEvents.add(_MixedEvent(
        timestamp: e.timestamp,
        type: 'emotion',
        text: e.emotion,
      ));
    }

    // 按时间排序
    allEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 生成混合文本
    final lines = <String>[];
    for (final e in allEvents) {
      if (e.type == 'dialog') {
        String label;
        if (e.speakerId == null || e.speakerId == 0) {
          label = '某';
        } else {
          label = String.fromCharCode(65 + e.speakerId! - 1);
        }
        lines.add('【$label说】：${e.text}');
      } else {
        lines.add('💭 ${e.text}');
      }
    }

    return lines.join('\n');
  }

  String _getOrAssignLabel(int speakerId) {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    if (!_speakerLabelMap.containsKey(speakerId)) {
      _speakerLabelMap[speakerId] = _nextLabelIndex;
      _speakerInfos[speakerId] = SpeakerRoleInfo(
        speakerId: speakerId,
        label: labels[_nextLabelIndex % labels.length],
      );
      _nextLabelIndex++;
    }
    return _speakerInfos[speakerId]!.label;
  }

  Future<void> startRecording() async {
    if (isRecording.value) return;
    //
    final customerCtrl = Get.find<CustomerCtrl>();
    if (!customerCtrl.isLoaded.value) {
      Get.snackbar('提示', '请先选择服务对象', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!customerCtrl.isRecording.value) {
      final myCtrl = Get.find<MyCtrl>();
      Get.defaultDialog(
        title: "提示",
        middleText: "是否同步开启脑波检测？",
        onConfirm: () {
          myCtrl.clearData();
          customerCtrl.sampleSize.value = 2048;
          customerCtrl.isRecording.value = true;
          Get.back();
        },
        onCancel: () => Get.back(),
      );
    }
    // 重置所有状态
    _resetState();
    _isSessionActive = true;

    state.value = AIDialogState.connecting;
    errorMessage.value = '正在连接...';

    await _asrService.startRecording();

    // 启动定时重新分析（每60秒）
    _reanalysisTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _reAnalyze();
    });

    // 启动提示问题定时器
    _hintTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _generateHint();
    });
  }

  void _resetState() {
    currentFullText.value = '';
    _lastDisplayText = '';
    _speakerTexts.clear();
    processedDialogs.clear();
    hints.clear();
    _shownHints.clear();
    _speakerLabelMap.clear();
    _speakerInfos.clear();
    _nextLabelIndex = 0;
    _emotionEvents.clear();
    errorMessage.value = '';
    cardohReportMarkdown.value = '';
  }

  Future<void> stopRecording() async {
    if (!isRecording.value && state.value == AIDialogState.idle) return;

    _isSessionActive = false;

    _reanalysisTimer?.cancel();
    _reanalysisTimer = null;
    _hintTimer?.cancel();
    _hintTimer = null;

    await _asrService.stopRecording();
    state.value = AIDialogState.idle;
    isRecording.value = false;

    // 停止前做一次最终分析
    _reAnalyze();

    // 判断是否显示"生成报告"按钮（文本超过100字）
    _showReportButton.value = currentFullText.value.length > 100;
    //
    final customerCtrl = Get.find<CustomerCtrl>();
    if (customerCtrl.isRecording.value) {
      final myCtrl = Get.find<MyCtrl>();
      Get.defaultDialog(
        title: "提示",
        middleText: "是否同步停止脑波检测？",
        onConfirm: () {
          myCtrl.gameover();
          Get.back();
        },
        onCancel: () => Get.back(),
      );
    }
  }

  // ==================== 报告相关方法 ====================

  /// 获取报告存储目录
  Future<Directory> _getReportDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final reportDir = Directory('${appDir.path}/card_oh_reports');
    if (!await reportDir.exists()) {
      await reportDir.create(recursive: true);
    }
    return reportDir;
  }

  /// 加载已存储的报告列表
  Future<void> _loadReportList() async {
    try {
      final dir = await _getReportDirectory();
      final files = await dir.list().toList();

      final reports = <ReportInfo>[];
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.md')) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          // 解析文件名格式：card_oh_report_客户昵称_YYYYMMDD_HHmmss.md
          // dateStr固定为13字符（YYYYMMDD_HHmmss）
          String title = '匿名';
          try {
            // 去掉前缀和后缀，剩余部分即为 "客户昵称_YYYYMMDD_HHmmss"
            final remaining = fileName.replaceFirst('card_oh_report_', '').replaceFirst('.md', '');
            if (remaining.length > 14) {
              // 前缀是客户昵称（长度 = 总长度 - 13位日期时间）
              title = remaining.substring(0, remaining.length - 14);
              if (title.isEmpty) title = '匿名';
            }
          } catch (_) {
            title = '匿名';
          }

          final stat = await entity.stat();
          reports.add(ReportInfo(
            fileName: fileName,
            title: title,
            createdAt: stat.modified,
          ));
        }
      }

      // 按时间倒序排列，最新的在最前面
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      reportList.assignAll(reports);
    } catch (_) {}
  }

  /// 生成并保存报告
  Future<bool> generateReport() async {
    // 检查是否正在生成
    if (isGeneratingReport.value) {
      Get.snackbar('提示', '报告正在生成中...', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    // 检查是否有内容
    if (currentFullText.value.isEmpty) {
      Get.snackbar('提示', '请先进行录音', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    isGeneratingReport.value = true;

    try {
      // 获取疗愈师和来访者姓名
      String therapistName = '疗愈师';
      String clientName = '来访者';
      try {
        final employeeCtrl = Get.find<EmployeeCtrl>();
        therapistName = employeeCtrl.nickname.value.isNotEmpty ? employeeCtrl.nickname.value : '疗愈师';
      } catch (_) {}
      try {
        final customerCtrl = Get.find<CustomerCtrl>();
        clientName = customerCtrl.nickname.value.isNotEmpty ? customerCtrl.nickname.value : '来访者';
      } catch (_) {}

      // 构建对话内容（使用混合文本：对话 + 情绪）
      final dialogContent = _generateMixedText();

      // 限制字数：超过5000字时只取最新5000字（越到最后的内容越有价值）
      final limitedContent = dialogContent.length > 5000 ? dialogContent.substring(dialogContent.length - 5000) : dialogContent;

      // 显示"正在生成"的提示（不自动消失）
      Get.snackbar(
        '提示',
        '正在生成报告...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(hours: 1), // 长时间显示，直到手动关闭
        showProgressIndicator: true,
      );

      // 调用Coze生成报告
      final markdown = await CozeReportService.generateReport(
        therapistName: therapistName,
        clientName: clientName,
        dialogDate: DateTime.now(),
        dialogContent: limitedContent,
      );

      if (markdown.isEmpty) {
        isGeneratingReport.value = false;
        Get.closeCurrentSnackbar(); // 关闭"正在生成"提示
        Get.snackbar('错误', '报告生成失败，请重试', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      cardohReportMarkdown.value = markdown;

      // 保存报告（使用顾客昵称）
      await _saveReport(markdown, clientName);

      // 重新加载报告列表
      await _loadReportList();

      isGeneratingReport.value = false;
      Get.closeCurrentSnackbar(); // 关闭"正在生成"提示
      Get.snackbar('成功', '报告已生成', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      isGeneratingReport.value = false;
      Get.snackbar('错误', '报告生成异常: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  /// 保存报告到本地
  /// [clientName] 顾客昵称，用于文件名（如果没有则显示"匿名"）
  Future<void> _saveReport(String markdown, String clientName) async {
    try {
      final dir = await _getReportDirectory();
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      // 使用顾客昵称，如果没有则显示"匿名"
      final displayName = (clientName.isEmpty || clientName == '来访者') ? '匿名' : clientName;
      final fileName = 'card_oh_report_${displayName}_$dateStr.md';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(markdown);
    } catch (_) {}
  }

  /// 读取报告内容
  Future<String> readReport(String fileName) async {
    try {
      final dir = await _getReportDirectory();
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {}
    return '';
  }

  /// 加载中文字体（用于PDF生成）
  /// 从 assets 目录加载 NotoSansSC
  Future<pw.Font?> _loadChineseFont() async {
    try {
      // 使用 rootBundle 从 assets 加载字体
      final fontData = await rootBundle.load('assets/fonts/NotoSansSC.ttf');
      // pdf 包使用 Font.ttf() 加载 TTF 数据
      return pw.Font.ttf(fontData.buffer.asByteData());
    } catch (_) {}
    return null;
  }

  /// 生成PDF报告（返回字节数据）
  Future<Uint8List?> generatePdfBytes(String fileName) async {
    try {
      final markdown = await readReport(fileName);
      if (markdown.isEmpty) return null;

      // 加载中文字体
      final chineseFont = await _loadChineseFont();

      final pdf = pw.Document();
      final pdfContent = _parseMarkdownToPdf(markdown, chineseFont);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => pdfContent,
        ),
      );

      return await pdf.save();
    } catch (e) {
      return null;
    }
  }

  /// 分享报告（Markdown或PDF）
  Future<void> shareReport(ReportInfo reportInfo, {bool asPdf = false}) async {
    try {
      if (asPdf) {
        // 使用 printing 包分享 PDF
        final pdfBytes = await generatePdfBytes(reportInfo.fileName);
        if (pdfBytes == null) {
          Get.snackbar('分享失败', 'PDF生成失败');
          return;
        }

        final pdfFileName = reportInfo.fileName.replaceAll('.md', '.pdf');
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: pdfFileName,
        );
      } else {
        // 分享原始Markdown
        final dir = await _getReportDirectory();
        final file = File('${dir.path}/${reportInfo.fileName}');
        if (!await file.exists()) {
          Get.snackbar('分享失败', '文件不存在');
          return;
        }

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: '疗愈报告 - ${reportInfo.title}',
          ),
        );
      }
    } catch (e) {
      Get.snackbar('分享失败', '无法分享报告');
    }
  }

  /// 使用 markdown 包解析 Markdown 内容为 PDF widgets
  /// 支持：标题、列表、加粗、斜体、行内代码
  /// [font] 中文字体，如果为null则使用默认字体
  List<pw.Widget> _parseMarkdownToPdf(String markdown, [pw.Font? font]) {
    final List<pw.Widget> widgets = [];
    final document = md.Document();

    // 使用 markdown 包解析
    final lines = markdown.split('\n');
    final blocks = document.parseLines(lines);

    // 创建文本样式
    pw.TextStyle titleStyle() => pw.TextStyle(font: font, fontSize: 22, fontWeight: pw.FontWeight.bold);
    pw.TextStyle h2Style() => pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold);
    pw.TextStyle h3Style() => pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold);
    pw.TextStyle h4Style() => pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold);
    pw.TextStyle bodyStyle() => pw.TextStyle(font: font, fontSize: 12);

    for (final block in blocks) {
      if (block is md.Element) {
        final tagName = block.tag;

        switch (tagName) {
          case 'h1':
            widgets.add(pw.SizedBox(height: 18));
            widgets.add(pw.Text(_renderInline(block), style: titleStyle()));
            widgets.add(pw.SizedBox(height: 12));
            break;
          case 'h2':
            widgets.add(pw.SizedBox(height: 16));
            widgets.add(pw.Text(_renderInline(block), style: h2Style()));
            widgets.add(pw.SizedBox(height: 10));
            break;
          case 'h3':
            widgets.add(pw.SizedBox(height: 14));
            widgets.add(pw.Text(_renderInline(block), style: h3Style()));
            widgets.add(pw.SizedBox(height: 8));
            break;
          case 'h4':
            widgets.add(pw.SizedBox(height: 12));
            widgets.add(pw.Text(_renderInline(block), style: h4Style()));
            widgets.add(pw.SizedBox(height: 6));
            break;
          case 'ul':
            // 无序列表
            final ulChildren = block.children;
            if (ulChildren != null) {
              for (final li in ulChildren) {
                if (li is md.Element && li.tag == 'li') {
                  widgets.add(pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 16, top: 4),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: bodyStyle()),
                        pw.Expanded(child: pw.Text(_renderInline(li), style: bodyStyle())),
                      ],
                    ),
                  ));
                }
              }
            }
            widgets.add(pw.SizedBox(height: 8));
            break;
          case 'ol':
            // 有序列表
            final olChildren = block.children;
            if (olChildren != null) {
              int idx = 1;
              for (final li in olChildren) {
                if (li is md.Element && li.tag == 'li') {
                  widgets.add(pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 16, top: 4),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('$idx. ', style: bodyStyle()),
                        pw.Expanded(child: pw.Text(_renderInline(li), style: bodyStyle())),
                      ],
                    ),
                  ));
                  idx++;
                }
              }
            }
            widgets.add(pw.SizedBox(height: 8));
            break;
          case 'p':
            // 段落
            final text = _renderInline(block);
            if (text.trim().isNotEmpty) {
              widgets.add(pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(text, style: bodyStyle()),
              ));
            }
            break;
          case 'blockquote':
            // 引用块
            final text = _renderInline(block);
            widgets.add(pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 4),
              padding: const pw.EdgeInsets.only(left: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: PdfColors.grey400, width: 3)),
              ),
              child: pw.Text(text, style: bodyStyle()),
            ));
            break;
          default:
            // 其他元素
            final text = _renderInline(block);
            if (text.isNotEmpty) {
              widgets.add(pw.Text(text, style: bodyStyle()));
            }
        }
      } else if (block is md.Text) {
        if (block.text.trim().isNotEmpty) {
          widgets.add(pw.Text(_stripInlineMarkdown(block.text), style: bodyStyle()));
        }
      }
    }

    return widgets;
  }

  /// 渲染行内元素（提取纯文本，自动去掉 Markdown 标记）
  String _renderInline(md.Element element) {
    final buffer = StringBuffer();
    final children = element.children;
    if (children != null) {
      for (final child in children) {
        if (child is md.Text) {
          buffer.write(_stripInlineMarkdown(child.text));
        } else if (child is md.Element) {
          // 递归处理子元素
          buffer.write(_renderInline(child));
        }
      }
    }
    return buffer.toString();
  }

  /// 去掉行内 Markdown 标记
  String _stripInlineMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1') // 加粗
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1') // 斜体
        .replaceAll(RegExp(r'`(.+?)`'), r'$1'); // 行内代码
  }

  /// 获取是否显示生成报告按钮
  bool get showReportButton => _showReportButton.value && !isGeneratingReport.value;

  /// 重新分析并生成对话视图
  /// 基于每个speaker的累积文本，按标点分割成句子后分析
  void _reAnalyze() {
    // 重置每个speaker的问题/回答计数
    for (final info in _speakerInfos.values) {
      info.questionCount = 0;
      info.answerCount = 0;
    }

    // 1. 按标点分割每个speaker的文本，统计提问/回答
    final Map<int, List<String>> speakerSentences = {};
    for (final entry in _speakerTexts.entries) {
      final spkid = entry.key;
      final fullText = entry.value;
      final sentences = _splitIntoSentences(fullText);
      speakerSentences[spkid] = sentences;

      final info = _speakerInfos[spkid];
      if (info == null) continue;

      for (final sentence in sentences) {
        if (_isQuestion(sentence)) {
          info.questionCount++;
        } else {
          info.answerCount++;
        }
      }
    }

    // 2. 推断说话人角色
    _inferRoles();

    // 3. 生成处理后的对话列表（收集所有句子）
    final newDialogs = <ProcessedDialogEntry>[];

    for (final entry in speakerSentences.entries) {
      final spkid = entry.key;
      final sentences = entry.value;
      final info = _speakerInfos[spkid];
      if (info == null) continue;

      for (final sentence in sentences) {
        if (sentence.trim().isEmpty) continue;

        if (info.inferredRole != SpeakerRole.unknown) {
          newDialogs.add(ProcessedDialogEntry(
            speakerLabel: info.label,
            role: info.inferredRole,
            text: sentence.trim(),
          ));
        } else {
          newDialogs.add(ProcessedDialogEntry(
            speakerLabel: info.label,
            role: null,
            text: sentence.trim(),
          ));
        }
      }
    }

    // 4. 添加提示问题
    for (final hint in hints) {
      newDialogs.add(ProcessedDialogEntry(
        speakerLabel: '💡',
        text: hint,
        isHint: true,
      ));
    }

    // 5. 更新UI
    processedDialogs.assignAll(newDialogs);
  }

  /// 按标点分割文本为句子
  List<String> _splitIntoSentences(String text) {
    if (text.isEmpty) return [];

    // 按中英文标点分割
    final pattern = RegExp(r'[。！？.!?]');
    final parts = text.split(pattern);

    return parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  bool _isQuestion(String text) {
    final trimmed = text.trim();
    if (trimmed.endsWith('?') || trimmed.endsWith('？')) return true;
    const questionWords = ['什么', '怎么', '为什么', '如何', '是不是', '能不能', '会不会', '有没有', '可以', '吗', '呢', '吧'];
    for (final word in questionWords) {
      if (trimmed.contains(word)) return true;
    }
    return false;
  }

  void _inferRoles() {
    final speakers = _speakerInfos.values.toList();

    if (speakers.isEmpty) return;

    if (speakers.length == 1) {
      // 只有一个人：保持unknown（待确认）
      speakers[0].inferredRole = SpeakerRole.unknown;
      return;
    }

    // 有多个人：根据发言模式判断
    for (final info in speakers) {
      final ratio = info.questionRatio;
      if (ratio > 0.4) {
        // 提问比例较高 → 疗愈师
        info.inferredRole = SpeakerRole.therapist;
      } else {
        // 提问比例较低 → 顾客
        info.inferredRole = SpeakerRole.client;
      }
    }
  }

  Future<void> _generateHint() async {
    if (_speakerTexts.isEmpty && _emotionEvents.isEmpty) return;

    // 构建对话上下文（使用混合文本：对话 + 情绪）
    final conversation = _generateMixedText();

    // 文本字数限制：超过500字时只取最新500字
    final truncated = conversation.length > 500 ? conversation.substring(conversation.length - 500) : conversation;

    // 调用Coze生成提示问题（Bot内部已做去重）
    final question = await CozeHintService.generateHint(
      conversation: truncated,
    );

    if (question.isNotEmpty) {
      _addHint(question);
    }
  }

  void _addHint(String question) {
    if (!_shownHints.contains(question)) {
      _shownHints.add(question);
      hints.add(question);
    }
  }

  String getConversationSummary() {
    if (_speakerTexts.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('# 卡牌疗愈对话记录\n');

    buffer.writeln('## 完整记录\n');
    for (final entry in _speakerTexts.entries) {
      final info = _speakerInfos[entry.key];
      final label = info?.label ?? '未知';
      buffer.writeln('【$label说】${entry.value}');
    }

    if (processedDialogs.isNotEmpty) {
      buffer.writeln('\n## 对话整理\n');
      for (final e in processedDialogs) {
        if (e.isHint) {
          buffer.writeln('💡 提示：${e.text}');
        } else {
          final roleName = e.role == SpeakerRole.therapist ? '疗愈师' : (e.role == SpeakerRole.client ? '顾客' : '待确认');
          buffer.writeln('[$roleName ${e.speakerLabel}] ${e.text}');
        }
      }
    }

    return buffer.toString();
  }
}

// ==================== AI对话滑动界面 ====================

class AIDialogSheet extends StatelessWidget {
  const AIDialogSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const _AIDialogContent(),
    );
  }
}

class _AIDialogContent extends StatelessWidget {
  const _AIDialogContent();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AIDialogCtrl>(
      init: Get.find<AIDialogCtrl>(),
      builder: (ctrl) {
        return Column(
          children: [
            _buildHeader(ctrl),
            Obx(() {
              if (ctrl.errorMessage.isEmpty) return const SizedBox.shrink();
              return _buildErrorBanner(ctrl.errorMessage.value);
            }),
            Expanded(
              child: Row(
                children: [
                  // ========== 左侧：完整记录 ==========
                  Expanded(child: _buildLeftPanel(ctrl)),
                  // 分隔线
                  Container(width: 1, color: Colors.grey[300]),
                  // ========== 右侧：对话区域 ==========
                  Expanded(child: _buildRightPanel(ctrl)),
                ],
              ),
            ),
            _buildActionBar(ctrl),
          ],
        );
      },
    );
  }

  Widget _buildHeader(AIDialogCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Text('AI对话疗愈', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Obx(() {
            if (ctrl.state.value == AIDialogState.connecting) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 4),
                    Text('连接中...', style: TextStyle(color: Colors.orange[700], fontSize: 12)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // 只关闭窗体，不影响录音状态
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red[700], fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// 左侧：完整记录（显示最新全文）
  Widget _buildLeftPanel(AIDialogCtrl ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Icon(Icons.text_snippet, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text('完整记录', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        // 内容：直接显示最新全文（覆盖，不是追加）
        Expanded(
          child: Obx(() {
            // 在Obx内部获取controller，才能正确监听observable变化
            final aiCtrl = Get.find<AIDialogCtrl>();
            final text = aiCtrl.currentFullText.value;
            if (text.isEmpty) {
              return Center(
                child: Text('完整记录将显示在这里...', style: TextStyle(color: Colors.grey[500])),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 右侧：对话区域
  Widget _buildRightPanel(AIDialogCtrl ctrl) {
    // 右侧：只显示提示性问题
    return Obx(() {
      final aiCtrl = Get.find<AIDialogCtrl>();
      final hintList = aiCtrl.hints;
      final recording = aiCtrl.isRecording.value;

      if (hintList.isEmpty && !recording) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '点击下方按钮开始',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '提示问题将在这里显示',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        );
      }

      if (hintList.isEmpty && recording) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, size: 48, color: Colors.green),
              const SizedBox(height: 8),
              Text('正在聆听...', style: TextStyle(color: Colors.green[700])),
              Text(
                '提示问题生成中',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text('提示问题', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(
                  '${hintList.length}条',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // 提示列表（最新在底部）
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: hintList.length,
              itemBuilder: (context, index) {
                return _HintBubble(text: hintList[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionBar(AIDialogCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ========== 按钮区 ==========
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final aiCtrl = Get.find<AIDialogCtrl>();
              final recording = aiCtrl.isRecording.value;
              final isGenerating = aiCtrl.isGeneratingReport.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 生成报告按钮（录音停止后且文本>500字）
                  if (aiCtrl.showReportButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton.icon(
                        onPressed: aiCtrl.generateReport,
                        icon: isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.description),
                        label: Text(isGenerating ? '生成中...' : '生成报告'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),

                  // 录音按钮
                  if (!recording)
                    ElevatedButton.icon(
                      onPressed: aiCtrl.startRecording,
                      icon: const Icon(Icons.mic),
                      label: const Text('开始录音'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: aiCtrl.stopRecording,
                      icon: const Icon(Icons.stop),
                      label: const Text('停止录音'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                ],
              );
            }),
          ),

          // ========== 报告抽屉区 ==========
          _buildReportsDrawer(ctrl),
        ],
      ),
    );
  }

  /// 横向滑动的报告抽屉区
  /// 横向滑动的报告抽屉区（始终显示）
  Widget _buildReportsDrawer(AIDialogCtrl ctrl) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Row(
              children: [
                Icon(Icons.folder_open, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '报告列表',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // 报告内容区
          Expanded(
            child: Obx(() {
              final reports = ctrl.reportList;
              if (reports.isEmpty) {
                // 空状态提示
                return Center(
                  child: Text(
                    '暂无报告，录音结束后可生成',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                );
              }
              // 有报告时横向滚动显示
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return _ReportFileIcon(
                    report: report,
                    onTap: () => _showReportViewer(ctrl, report),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 显示报告查看器
  void _showReportViewer(AIDialogCtrl ctrl, ReportInfo report) {
    Get.bottomSheet(
      _ReportViewerSheet(report: report, ctrl: ctrl),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

/// 报告文件图标组件
class _ReportFileIcon extends StatelessWidget {
  final ReportInfo report;
  final VoidCallback onTap;

  const _ReportFileIcon({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, color: Colors.blue[600], size: 24),
            const SizedBox(height: 2),
            Text(
              _formatDate(report.createdAt),
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// 报告查看器
class _ReportViewerSheet extends StatelessWidget {
  final ReportInfo report;
  final AIDialogCtrl ctrl;

  const _ReportViewerSheet({required this.report, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(Icons.description, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDateTime(report.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                // 分享按钮
                IconButton(
                  icon: const Icon(Icons.share, size: 22),
                  onPressed: () => _showShareOptions(context),
                  tooltip: '分享',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // 报告内容（使用 Markdown 渲染）
          Expanded(
            child: FutureBuilder<String>(
              future: ctrl.readReport(report.fileName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('无法加载报告', style: TextStyle(color: Colors.grey[600])),
                  );
                }
                return Markdown(
                  data: snapshot.data!,
                  padding: const EdgeInsets.all(16),
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 14, height: 1.6),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    h4: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 显示分享选项
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('分享 Markdown'),
              subtitle: const Text('分享原始文本格式'),
              onTap: () {
                Navigator.pop(context);
                ctrl.shareReport(report, asPdf: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('分享 PDF'),
              subtitle: const Text('生成并分享PDF文件'),
              onTap: () {
                Navigator.pop(context);
                ctrl.shareReport(report, asPdf: true);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 提示问题气泡组件
class _HintBubble extends StatelessWidget {
  final String text;

  const _HintBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.amber[900], fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class CardohReportView extends GetView<AIDialogCtrl> {
  CardohReportView({super.key});

  @override
  final controller = Get.put(AIDialogCtrl());
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: Obx(() => Container(
              margin: EdgeInsets.all(20),
              child: MarkdownBody(
                data: controller.cardohReportMarkdown.value,
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(fontSize: 24, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                  h2: TextStyle(fontSize: 20, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                  h3: TextStyle(fontSize: 18, color: colorPrimaryContainer, fontWeight: FontWeight.bold),
                  p: TextStyle(fontSize: 16, color: colorPrimaryContainer),
                ),
              ),
            )));
  }
}
