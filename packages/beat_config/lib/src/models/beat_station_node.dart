import 'package:beat_config/beat_config.dart';
import 'package:json_annotation/json_annotation.dart';

part 'beat_station_node.g.dart';

@JsonSerializable()
class BeatStationNode {
  // node info
  final BeatStationInfo info;
  // parent enum class name
  String parent;
  // compound related to enum field
  final Map<String, List<BeatStationNode>> children;
  // compounds included in this station
  final Map<String, List<SubstationConfig>> substationConfigs;
  // beats included in this station
  final Map<String, List<BeatConfig>> beatConfigs;
  // invokes included in this station
  final Map<String, List<InvokeConfig>> invokeConfigs;

  BeatStationNode(
    this.info, {
    this.parent = '',
    this.children = const {},
    this.substationConfigs = const {},
    this.beatConfigs = const {},
    this.invokeConfigs = const {},
  });

  Map<String, dynamic> toJson() => _$BeatStationNodeToJson(this);
  factory BeatStationNode.fromJson(Map<String, dynamic> json) =>
      _$BeatStationNodeFromJson(json);
}
