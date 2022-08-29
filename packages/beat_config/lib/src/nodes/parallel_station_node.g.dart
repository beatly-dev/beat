// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parallel_station_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParallelStationNode _$ParallelStationNodeFromJson(Map<String, dynamic> json) =>
    ParallelStationNode(
      id: json['id'] as String?,
      name: json['name'] as String,
      vars: (json['vars'] as List<dynamic>).map((e) => e as String).toList(),
      stationName: Map<String, String>.from(json['stationName'] as Map),
      withFlutter: json['withFlutter'] as bool,
      initialStates: Map<String, String>.from(json['initialStates'] as Map),
    );

Map<String, dynamic> _$ParallelStationNodeToJson(
        ParallelStationNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vars': instance.vars,
      'stationName': instance.stationName,
      'initialStates': instance.initialStates,
      'withFlutter': instance.withFlutter,
    };
