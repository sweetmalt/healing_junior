// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eeg_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EEGDataModel _$EEGDataModelFromJson(Map<String, dynamic> json) => EEGDataModel(
  poorSignal: (json['poorSignal'] as num?)?.toInt(),
  attention: (json['attention'] as num?)?.toInt(),
  meditation: (json['meditation'] as num?)?.toInt(),
  rawData: (json['rawData'] as num?)?.toInt(),
  delta: (json['delta'] as num?)?.toInt(),
  theta: (json['theta'] as num?)?.toInt(),
  lowAlpha: (json['lowAlpha'] as num?)?.toInt(),
  highAlpha: (json['highAlpha'] as num?)?.toInt(),
  lowBeta: (json['lowBeta'] as num?)?.toInt(),
  highBeta: (json['highBeta'] as num?)?.toInt(),
  lowGamma: (json['lowGamma'] as num?)?.toInt(),
  midGamma: (json['midGamma'] as num?)?.toInt(),
);

Map<String, dynamic> _$EEGDataModelToJson(EEGDataModel instance) =>
    <String, dynamic>{
      'poorSignal': instance.poorSignal,
      'attention': instance.attention,
      'meditation': instance.meditation,
      'rawData': instance.rawData,
      'delta': instance.delta,
      'theta': instance.theta,
      'lowAlpha': instance.lowAlpha,
      'highAlpha': instance.highAlpha,
      'lowBeta': instance.lowBeta,
      'highBeta': instance.highBeta,
      'lowGamma': instance.lowGamma,
      'midGamma': instance.midGamma,
    };
