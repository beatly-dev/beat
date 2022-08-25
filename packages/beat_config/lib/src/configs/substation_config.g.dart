// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'substation_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubstationConfig _$SubstationConfigFromJson(Map<String, dynamic> json) =>
    SubstationConfig(
      parentBase: json['parentBase'] as String,
      parentField: json['parentField'] as String,
      childBase: json['childBase'] as String,
      source: json['source'] as String,
    );

Map<String, dynamic> _$SubstationConfigToJson(SubstationConfig instance) =>
    <String, dynamic>{
      'parentBase': instance.parentBase,
      'parentField': instance.parentField,
      'childBase': instance.childBase,
      'source': instance.source,
    };
