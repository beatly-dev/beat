// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beat_station_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeatStationInfo _$BeatStationInfoFromJson(Map<String, dynamic> json) =>
    BeatStationInfo(
      baseEnumName: json['baseEnumName'] as String,
      contextType: json['contextType'] as String,
      states:
          (json['states'] as List<dynamic>).map((e) => e as String).toList(),
      withFlutter: json['withFlutter'] as bool? ?? false,
    );

Map<String, dynamic> _$BeatStationInfoToJson(BeatStationInfo instance) =>
    <String, dynamic>{
      'baseEnumName': instance.baseEnumName,
      'contextType': instance.contextType,
      'states': instance.states,
      'withFlutter': instance.withFlutter,
    };
