import 'package:json_annotation/json_annotation.dart';

part 'beat_config.g.dart';

@JsonSerializable()
class BeatConfig {
  final String event;
  final String fromBase;
  final String fromField;
  final String toBase;
  final String toField;
  final String? actions;
  final String? eventDataType;
  final String? conditions;
  final String source;
  final bool eventless;
  final String after;

  const BeatConfig({
    required this.event,
    required this.fromBase,
    required this.fromField,
    required this.toBase,
    required this.toField,
    required this.source,
    this.actions,
    this.conditions,
    this.eventDataType,
    this.eventless = false,
    this.after = 'const Duration(milliseconds: 0)',
  });

  factory BeatConfig.fromJson(Map<String, dynamic> json) =>
      _$BeatConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BeatConfigToJson(this);

  @override
  String toString() {
    return '''from `$fromBase.$fromField` to `$toBase.$toField` by `$event`, 
    actions: $actions, eventDataType: $eventDataType, conditions: $conditions
    eventless: $eventless, after: $after''';
  }
}
