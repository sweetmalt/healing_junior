// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eeg_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EEGDataModel _$EEGDataModelFromJson(Map<String, dynamic> json) => EEGDataModel(
  poorSignal: (json['poorSignal'] as num?)?.toInt(),
  attention: (json['attention'] as num?)?.toInt(),
  meditation: (json['meditation'] as num?)?.toInt(),
  delta: (json['delta'] as num?)?.toInt(),
  theta: (json['theta'] as num?)?.toInt(),
  alpha: (json['alpha'] as num?)?.toInt(),
  beta: (json['beta'] as num?)?.toInt(),
  gamma: (json['gamma'] as num?)?.toInt(),
  heartRate: (json['heartRate'] as num?)?.toInt(),
  spO2: (json['spO2'] as num?)?.toInt(),
  foreheadTemp: (json['foreheadTemp'] as num?)?.toInt(),
  battery: (json['battery'] as num?)?.toInt(),
);

Map<String, dynamic> _$EEGDataModelToJson(EEGDataModel instance) =>
    <String, dynamic>{
      'poorSignal': instance.poorSignal,
      'attention': instance.attention,
      'meditation': instance.meditation,
      'delta': instance.delta,
      'theta': instance.theta,
      'alpha': instance.alpha,
      'beta': instance.beta,
      'gamma': instance.gamma,
      'heartRate': instance.heartRate,
      'spO2': instance.spO2,
      'foreheadTemp': instance.foreheadTemp,
      'battery': instance.battery,
    };
