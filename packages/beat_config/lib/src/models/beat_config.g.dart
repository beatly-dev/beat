// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beat_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeatConfig _$BeatConfigFromJson(Map<String, dynamic> json) => BeatConfig(
      event: json['event'] as String,
      fromBase: json['fromBase'] as String,
      fromField: json['fromField'] as String,
      toBase: json['toBase'] as String,
      toField: json['toField'] as String,
      source: json['source'] as String,
      actions: json['actions'] as String?,
      conditions: json['conditions'] as String?,
      eventDataType: json['eventDataType'] as String?,
    );

Map<String, dynamic> _$BeatConfigToJson(BeatConfig instance) =>
    <String, dynamic>{
      'event': instance.event,
      'fromBase': instance.fromBase,
      'fromField': instance.fromField,
      'toBase': instance.toBase,
      'toField': instance.toField,
      'actions': instance.actions,
      'eventDataType': instance.eventDataType,
      'conditions': instance.conditions,
      'source': instance.source,
    };
