import 'package:json_annotation/json_annotation.dart';

import '../configs/beat_config.dart';
import '../configs/service_config.dart';

part 'station_node.g.dart';

@JsonSerializable()
class BeatStationNode {
  /// Station id
  final String? id;

  /// Station's enum name
  final String name;

  /// Station
  final String contextType;

  /// default initial state
  final String initialState;

  /// default initial context;
  final String initialContext;

  /// enum fields
  final List<String> states;

  /// nested station related to enum field
  final Map<String, String> substations;

  /// beats included in this station
  final Map<String, List<BeatConfig>> beats;

  /// invokes included in this station
  final Map<String, List<ServiceConfig>> services;

  /// final state
  final List<String> finalState;

  /// OnEntry
  final String stationEntry;

  /// OnExit
  final String stationExit;

  /// OnEntry for each states
  final Map<String, String> stateEntry;

  /// OnExit for each states
  final Map<String, String> stateExit;

  /// need flutter widgets
  bool withFlutter;

  /// Original code of annotation
  final String? source;

  BeatStationNode({
    required this.id,
    required this.name,
    required this.states,
    required this.initialState,
    required this.initialContext,
    required this.contextType,
    required this.substations,
    required this.beats,
    required this.services,
    required this.finalState,
    required this.stationEntry,
    required this.stationExit,
    required this.stateEntry,
    required this.stateExit,
    required this.withFlutter,
    required this.source,
  });

  Map<String, dynamic> toJson() => _$BeatStationNodeToJson(this);
  factory BeatStationNode.fromJson(Map<String, dynamic> json) =>
      _$BeatStationNodeFromJson(json);
}
