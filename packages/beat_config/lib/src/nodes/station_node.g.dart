// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeatStationNode _$BeatStationNodeFromJson(Map<String, dynamic> json) =>
    BeatStationNode(
      id: json['id'] as String?,
      name: json['name'] as String,
      states:
          (json['states'] as List<dynamic>).map((e) => e as String).toList(),
      initialState: json['initialState'] as String,
      initialContext: json['initialContext'] as String,
      contextType: json['contextType'] as String,
      substations: Map<String, String>.from(json['substations'] as Map),
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
      finalState: (json['finalState'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stationEntry: json['stationEntry'] as String,
      stationExit: json['stationExit'] as String,
      stateEntry: Map<String, String>.from(json['stateEntry'] as Map),
      stateExit: Map<String, String>.from(json['stateExit'] as Map),
      withFlutter: json['withFlutter'] as bool,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$BeatStationNodeToJson(BeatStationNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contextType': instance.contextType,
      'initialState': instance.initialState,
      'initialContext': instance.initialContext,
      'states': instance.states,
      'substations': instance.substations,
      'beats': instance.beats,
      'services': instance.services,
      'finalState': instance.finalState,
      'stationEntry': instance.stationEntry,
      'stationExit': instance.stationExit,
      'stateEntry': instance.stateEntry,
      'stateExit': instance.stateExit,
      'withFlutter': instance.withFlutter,
      'source': instance.source,
    };
