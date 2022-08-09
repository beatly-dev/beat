// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beat_station_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeatStationNode _$BeatStationNodeFromJson(Map<String, dynamic> json) =>
    BeatStationNode(
      BeatStationInfo.fromJson(json['info'] as Map<String, dynamic>),
      parentBase: json['parentBase'] as String? ?? '',
      parentField: json['parentField'] as String? ?? '',
      children: (json['children'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) =>
                        BeatStationNode.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      substationConfigs: (json['substationConfigs'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) =>
                        SubstationConfig.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      beatConfigs: (json['beatConfigs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) => BeatConfig.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      invokeConfigs: (json['invokeConfigs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map(
                        (e) => InvokeConfig.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
    );

Map<String, dynamic> _$BeatStationNodeToJson(BeatStationNode instance) =>
    <String, dynamic>{
      'info': instance.info,
      'parentBase': instance.parentBase,
      'parentField': instance.parentField,
      'children': instance.children,
      'substationConfigs': instance.substationConfigs,
      'beatConfigs': instance.beatConfigs,
      'invokeConfigs': instance.invokeConfigs,
    };
