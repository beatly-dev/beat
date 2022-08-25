// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeatStationNode _$BeatStationNodeFromJson(Map<String, dynamic> json) =>
    BeatStationNode(
      id: json['id'] as String?,
      name: json['name'] as String,
      contextType: json['contextType'] as String,
      states:
          (json['states'] as List<dynamic>).map((e) => e as String).toList(),
      initialContext: json['initialContext'] as String,
      initialState: json['initialState'] as String,
      finalState: json['finalState'] as String?,
      withFlutter: json['withFlutter'] as bool? ?? false,
      children: Map<String, String>.from(json['children'] as Map),
      beats: (json['beats'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => BeatConfig.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      services: (json['services'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => ServiceConfig.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      entrySource: json['entrySource'] as String,
      exitSource: json['exitSource'] as String,
    );

Map<String, dynamic> _$BeatStationNodeToJson(BeatStationNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contextType': instance.contextType,
      'initialState': instance.initialState,
      'initialContext': instance.initialContext,
      'states': instance.states,
      'finalState': instance.finalState,
      'children': instance.children,
      'beats': instance.beats,
      'services': instance.services,
      'entrySource': instance.entrySource,
      'exitSource': instance.exitSource,
      'withFlutter': instance.withFlutter,
    };
