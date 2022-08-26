import 'package:json_annotation/json_annotation.dart';

part 'parallel_station_node.g.dart';

@JsonSerializable()
class ParallelStationNode {
  /// Station id
  final String? id;

  /// Station's enum name
  final String name;

  /// parallel stations enum name
  final List<String> stations;

  /// Parallel stations initial state
  final List<String> initialStates;

  /// need flutter widgets
  bool withFlutter;

  ParallelStationNode({
    required this.id,
    required this.name,
    required this.stations,
    required this.initialStates,
    required this.withFlutter,
  });

  Map<String, dynamic> toJson() => _$ParallelStationNodeToJson(this);
  factory ParallelStationNode.fromJson(Map<String, dynamic> json) =>
      _$ParallelStationNodeFromJson(json);
}
