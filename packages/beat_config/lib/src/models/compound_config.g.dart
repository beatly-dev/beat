// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compound_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompoundConfig _$CompoundConfigFromJson(Map<String, dynamic> json) =>
    CompoundConfig(
      parentBase: json['parentBase'] as String,
      parentField: json['parentField'] as String,
      childBase: json['childBase'] as String,
      childFirst: json['childFirst'] as String,
      source: json['source'] as String,
    );

Map<String, dynamic> _$CompoundConfigToJson(CompoundConfig instance) =>
    <String, dynamic>{
      'parentBase': instance.parentBase,
      'parentField': instance.parentField,
      'childBase': instance.childBase,
      'childFirst': instance.childFirst,
      'source': instance.source,
    };
