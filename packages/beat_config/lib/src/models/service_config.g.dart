// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceConfig _$ServiceConfigFromJson(Map<String, dynamic> json) =>
    ServiceConfig(
      stateBase: json['stateBase'] as String,
      stateField: json['stateField'] as String,
      source: json['source'] as String,
    );

Map<String, dynamic> _$ServiceConfigToJson(ServiceConfig instance) =>
    <String, dynamic>{
      'stateBase': instance.stateBase,
      'stateField': instance.stateField,
      'source': instance.source,
    };
