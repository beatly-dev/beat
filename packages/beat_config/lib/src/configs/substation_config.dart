import 'package:json_annotation/json_annotation.dart';

part 'substation_config.g.dart';

@JsonSerializable()
class SubstationConfig {
  final String parentBase;
  final String parentField;
  final String childBase;
  final String source;

  SubstationConfig(
      {required this.parentBase,
      required this.parentField,
      required this.childBase,
      required this.source});
  Map<String, dynamic> toJson() => _$SubstationConfigToJson(this);
  factory SubstationConfig.fromJson(Map<String, dynamic> json) =>
      _$SubstationConfigFromJson(json);
}
