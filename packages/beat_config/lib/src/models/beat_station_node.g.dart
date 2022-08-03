// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beat_station_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeatStationNode _$BeatStationNodeFromJson(Map<String, dynamic> json) =>
    BeatStationNode(
      BeatStationInfo.fromJson(json['info'] as Map<String, dynamic>),
      parent: json['parent'] as String? ?? '',
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => BeatStationNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      compoundConfigs: (json['compoundConfigs'] as List<dynamic>?)
              ?.map((e) => CompoundConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      beatConfigs: (json['beatConfigs'] as List<dynamic>?)
              ?.map((e) => BeatConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      invokeConfigs: (json['invokeConfigs'] as List<dynamic>?)
              ?.map((e) => InvokeConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BeatStationNodeToJson(BeatStationNode instance) =>
    <String, dynamic>{
      'info': instance.info,
      'parent': instance.parent,
      'children': instance.children,
      'compoundConfigs': instance.compoundConfigs,
      'beatConfigs': instance.beatConfigs,
      'invokeConfigs': instance.invokeConfigs,
    };
