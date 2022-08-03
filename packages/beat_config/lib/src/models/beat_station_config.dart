import 'package:json_annotation/json_annotation.dart';

part 'beat_station_config.g.dart';

@JsonSerializable()
class BeatStationInfo {
  final String baseEnumName;
  final String contextType;
  final List<String> states;

  const BeatStationInfo({
    required this.baseEnumName,
    required this.contextType,
    required this.states,
  });

  Map<String, dynamic> toJson() => _$BeatStationInfoToJson(this);
  factory BeatStationInfo.fromJson(Map<String, dynamic> json) =>
      _$BeatStationInfoFromJson(json);
}
