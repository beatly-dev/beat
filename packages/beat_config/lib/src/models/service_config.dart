import 'package:json_annotation/json_annotation.dart';

part 'service_config.g.dart';

@JsonSerializable()
class ServiceConfig {
  final String stateBase;
  final String stateField;
  final String source;

  const ServiceConfig({
    required this.stateBase,
    required this.stateField,
    required this.source,
  });

  factory ServiceConfig.fromJson(Map<String, dynamic> json) =>
      _$ServiceConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceConfigToJson(this);
}
