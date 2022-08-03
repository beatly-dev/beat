import 'package:beat_config/beat_config.dart';
import 'package:json_annotation/json_annotation.dart';

part 'beat_station_node.g.dart';

@JsonSerializable()
class BeatStationNode {
  final BeatStationInfo info;
  final String parent;
  final List<BeatStationNode> children;
  final List<CompoundConfig> compoundConfigs;
  final List<BeatConfig> beatConfigs;
  final List<InvokeConfig> invokeConfigs;

  const BeatStationNode(
    this.info, {
    this.parent = '',
    this.children = const [],
    this.compoundConfigs = const [],
    this.beatConfigs = const [],
    this.invokeConfigs = const [],
  });

  Map<String, dynamic> toJson() => _$BeatStationNodeToJson(this);
  factory BeatStationNode.fromJson(Map<String, dynamic> json) =>
      _$BeatStationNodeFromJson(json);
}
