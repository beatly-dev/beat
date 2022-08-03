import 'package:json_annotation/json_annotation.dart';

part 'invoke_config.g.dart';

@JsonSerializable()
class InvokeConfig {
  final String stateBase;
  final String stateField;
  final String source;

  const InvokeConfig({
    required this.stateBase,
    required this.stateField,
    required this.source,
  });

  factory InvokeConfig.fromJson(Map<String, dynamic> json) =>
      _$InvokeConfigFromJson(json);
  Map<String, dynamic> toJson() => _$InvokeConfigToJson(this);
}
