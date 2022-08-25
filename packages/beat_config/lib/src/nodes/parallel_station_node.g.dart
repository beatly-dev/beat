// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parallel_station_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParallelStationNode _$ParallelStationNodeFromJson(Map<String, dynamic> json) =>
    ParallelStationNode(
      id: json['id'] as String?,
      name: json['name'] as String,
      withFlutter: json['withFlutter'] as bool? ?? false,
      stations: (json['stations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      initialStates: (json['initialStates'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ParallelStationNodeToJson(
        ParallelStationNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stations': instance.stations,
      'initialStates': instance.initialStates,
      'withFlutter': instance.withFlutter,
    };
