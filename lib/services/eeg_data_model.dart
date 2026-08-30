import 'package:json_annotation/json_annotation.dart';
part 'eeg_data_model.g.dart';

/// 佩戴状态档位（基于硬件协议文档 3.3 节 Signal 显示规则建议）
enum SignalLevel {
  good, // 0 佩戴良好
  slight, // 1~100 接触轻微不良 / 晃动
  poor, // 101~199 接触不良
  off, // 200 未佩戴 / 空闲
  unknown, // null 或其他
}

@JsonSerializable()
class EEGDataModel {
  int? poorSignal; // 信号质量 0-255, 0=佩戴良好, 200=未佩戴
  int? attention; // 专注度 0-100
  int? meditation; // 放松度 0-100
  int? delta; // Delta 脑波功率 (uint24 大端)
  int? theta; // Theta 脑波功率 (uint24 大端)
  int? alpha; // Alpha 脑波功率 = 低Alpha + 高Alpha
  int? beta; // Beta 脑波功率 = 低Beta + 高Beta
  int? gamma; // Gamma 脑波功率 = 低Gamma + 中Gamma
  int? heartRate; // 心率 (bpm)
  int? spO2; // 血氧 (%)
  int? foreheadTemp; // 额温 (℃)
  int? battery; // 电池电量 (0~100%)

  EEGDataModel({
    this.poorSignal,
    this.attention,
    this.meditation,
    this.delta,
    this.theta,
    this.alpha,
    this.beta,
    this.gamma,
    this.heartRate,
    this.spO2,
    this.foreheadTemp,
    this.battery,
  });

  /// 将 poorSignal 数值映射为佩戴状态档位
  static SignalLevel signalLevel(int? v) {
    if (v == null) return SignalLevel.unknown;
    if (v == 0) return SignalLevel.good;
    if (v >= 1 && v <= 100) return SignalLevel.slight;
    if (v >= 101 && v <= 199) return SignalLevel.poor;
    if (v == 200) return SignalLevel.off;
    return SignalLevel.unknown;
  }

  /// 将 poorSignal 数值映射为简短短语（用于导引按钮等简洁场景）
  static String signalLabel(int? v) {
    switch (signalLevel(v)) {
      case SignalLevel.good:
        return '佩戴良好';
      case SignalLevel.slight:
        return '接触轻微不良';
      case SignalLevel.poor:
        return '接触不良';
      case SignalLevel.off:
        return '未佩戴';
      case SignalLevel.unknown:
        return '未知';
    }
  }

  // 清空所有字段 (用于重置)
  void clear() {
    poorSignal = null;
    attention = null;
    meditation = null;
    delta = null;
    theta = null;
    alpha = null;
    beta = null;
    gamma = null;
    heartRate = null;
    spO2 = null;
    foreheadTemp = null;
    battery = null;
  }

  // 复制当前对象
  EEGDataModel copy() {
    return EEGDataModel(
      poorSignal: poorSignal,
      attention: attention,
      meditation: meditation,
      delta: delta,
      theta: theta,
      alpha: alpha,
      beta: beta,
      gamma: gamma,
      heartRate: heartRate,
      spO2: spO2,
      foreheadTemp: foreheadTemp,
      battery: battery,
    );
  }

  factory EEGDataModel.fromJson(Map<String, dynamic> json) =>
      _$EEGDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$EEGDataModelToJson(this);
}
