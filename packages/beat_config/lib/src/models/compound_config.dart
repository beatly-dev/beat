import 'package:json_annotation/json_annotation.dart';

part 'compound_config.g.dart';

@JsonSerializable()
class CompoundConfig {
  final String parentBase;
  final String parentField;
  final String childBase;
  final String childFirst;
  final String source;

  const CompoundConfig({
    required this.parentBase,
    required this.parentField,
    required this.childBase,
    required this.childFirst,
    required this.source,
  });

  Map<String, dynamic> toJson() => _$CompoundConfigToJson(this);
  factory CompoundConfig.fromJson(Map<String, dynamic> json) =>
      _$CompoundConfigFromJson(json);
}
