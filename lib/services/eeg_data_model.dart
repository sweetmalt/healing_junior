import 'package:json_annotation/json_annotation.dart';
part 'eeg_data_model.g.dart';
@JsonSerializable()
class EEGDataModel {
  int? poorSignal;      // 信号质量 0-255, 0=最好, 200=未接触
  int? attention;       // 专注度 0-100
  int? meditation;      // 放松度 0-100
  int? rawData;         // 原始数据 (有符号16位)
  int? delta;
  int? theta;
  int? lowAlpha;
  int? highAlpha;
  int? lowBeta;
  int? highBeta;
  int? lowGamma;
  int? midGamma;

  EEGDataModel({
    this.poorSignal,
    this.attention,
    this.meditation,
    this.rawData,
    this.delta,
    this.theta,
    this.lowAlpha,
    this.highAlpha,
    this.lowBeta,
    this.highBeta,
    this.lowGamma,
    this.midGamma,
  });

  // 清空所有字段 (用于重置)
  void clear() {
    poorSignal = null;
    attention = null;
    meditation = null;
    rawData = null;
    delta = null;
    theta = null;
    lowAlpha = null;
    highAlpha = null;
    lowBeta = null;
    highBeta = null;
    lowGamma = null;
    midGamma = null;
  }

  // 复制当前对象
  EEGDataModel copy() {
    return EEGDataModel(
      poorSignal: poorSignal,
      attention: attention,
      meditation: meditation,
      rawData: rawData,
      delta: delta,
      theta: theta,
      lowAlpha: lowAlpha,
      highAlpha: highAlpha,
      lowBeta: lowBeta,
      highBeta: highBeta,
      lowGamma: lowGamma,
      midGamma: midGamma,
    );
  }

  factory EEGDataModel.fromJson(Map<String, dynamic> json) =>
      _$EEGDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$EEGDataModelToJson(this);


}