import 'package:json_annotation/json_annotation.dart';

import '../nodes/nodes.dart';

part 'beat_store.g.dart';

const String beatCacheDir = '.dart_tool/beat';
const beatEntryPointDir = '$beatCacheDir/entrypoint';
const beatJsonLocation = '$beatEntryPointDir/beat_data.json';

@JsonSerializable()
class StationDataStore {
  @JsonKey(includeIfNull: false, disallowNullValue: false)
  late final Map<String, BeatStationNode> stations;

  @JsonKey(includeIfNull: false, disallowNullValue: false)
  late final Map<String, ParallelStationNode> parallels;

  StationDataStore({
    Map<String, BeatStationNode>? stations,
    Map<String, ParallelStationNode>? parallels,
  })  : stations = stations ?? {},
        parallels = parallels ?? {};

  addStation({BeatStationNode? station, ParallelStationNode? parallel}) {
    assert(station != null || parallel != null);

    if (station != null) {
      stations[station.name] = station;
    } else {
      parallels[parallel!.name] = parallel;
    }
  }

  removeStation(String name) {
    assert(name.isNotEmpty);
    stations.remove(name) ?? parallels.remove(name);
  }

  getStation(String name) {
    assert(name.isNotEmpty);
    return stations[name] ?? parallels[name];
  }

  Map<String, dynamic> toJson() => _$StationDataStoreToJson(this);
  factory StationDataStore.fromJson(Map<String, dynamic> json) =>
      _$StationDataStoreFromJson(json);
}
