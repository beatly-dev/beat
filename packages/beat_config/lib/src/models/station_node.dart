import 'package:beat_config/beat_config.dart';
import 'package:json_annotation/json_annotation.dart';

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

  /// final state
  final String? finalState;

  /// nested station related to enum field
  final Map<String, String> children;

  /// beats included in this station
  final Map<String, List<BeatConfig>> beats;

  /// invokes included in this station
  final Map<String, List<ServiceConfig>> services;

  /// OnEntry
  final String entrySource;

  /// OnExit
  final String exitSource;

  /// need flutter widgets
  bool withFlutter;

  BeatStationNode({
    this.id,
    required this.name,
    required this.contextType,
    required this.states,
    required this.initialContext,
    required this.initialState,
    this.finalState,
    this.withFlutter = false,
    required this.children,
    required this.beats,
    required this.services,
    required this.entrySource,
    required this.exitSource,
  });

  Map<String, dynamic> toJson() => _$BeatStationNodeToJson(this);
  factory BeatStationNode.fromJson(Map<String, dynamic> json) =>
      _$BeatStationNodeFromJson(json);
}
