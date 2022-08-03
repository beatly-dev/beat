import 'package:json_annotation/json_annotation.dart';

part 'compound_config.g.dart';

@JsonSerializable()
class SubstationConfig {
  final String parentBase;
  final String parentField;
  final String childBase;
  final String childFirst;
  final String source;

  const SubstationConfig({
    required this.parentBase,
    required this.parentField,
    required this.childBase,
    required this.childFirst,
    required this.source,
  });

  Map<String, dynamic> toJson() => _$SubstationConfigToJson(this);
  factory SubstationConfig.fromJson(Map<String, dynamic> json) =>
      _$SubstationConfigFromJson(json);
}
