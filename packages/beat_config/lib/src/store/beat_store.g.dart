// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beat_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StationDataStore _$StationDataStoreFromJson(Map<String, dynamic> json) =>
    StationDataStore(
      (json['stations'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, BeatStationNode.fromJson(e as Map<String, dynamic>)),
      ),
      (json['parallels'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ParallelStationNode.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$StationDataStoreToJson(StationDataStore instance) =>
    <String, dynamic>{
      'parallels': instance.parallels,
      'stations': instance.stations,
    };
