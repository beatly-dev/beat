import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../utils/constant_reader.dart';
import 'annotation_aggregator.dart';
import 'annotation_field.dart';

Future<List<BeatConfig>> aggregateBeatConfigs(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) async {
  final annotations =
      await aggregateAnnotations(element, _beatChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) {
    final annotation = ConstantReader(e.annotationObj);

    final event = getAnnotationFieldLiteralValue(annotation, 'event');
    final fromField = e.element.name!;
    final toField = getAnnotationEnumFieldValue(annotation, 'to');
    final toBase = getAnnotationEnumFieldClass(annotation, 'to');
    final source = e.source;
    final actions = getBeatActionsField(source);
    final argType = getBeatArgTypeField(annotation);
    final conditions = getBeatConditionsField(source);

    final config = BeatConfig(
      fromBase: fromBase!,
      fromField: fromField,
      event: event,
      toBase: toBase,
      toField: toField,
      source: source,
      actions: actions,
      eventDataType: argType,
      conditions: conditions,
    );
    return config;
  }).toList();
}

Future<Map<String, List<BeatConfig>>> mapBeatAnnotations<C>(
  String stateName,
  List<Element> fields,
  BuildStep buildStep,
) async {
  final beats = <String, List<BeatConfig>>{};
  for (final field in fields) {
    final beatConfigs = await aggregateBeatConfigs(field, stateName, buildStep);
    final from = field.name!;
    beats[from] = beatConfigs;
    if (field is ClassElement) {
      final fieldBeats =
          await mapBeatAnnotations(stateName, field.fields, buildStep);
      beats.addAll(fieldBeats);
    }
  }
  return beats;
}

String? getBeatActionsField(String source) {
  return getListField(source, 'actions');
}

String? getBeatArgTypeField(ConstantReader reader) {
  return getTypeField(reader, 'eventDataType');
}

String? getBeatConditionsField(String source) {
  return getListField(source, 'conditions');
}

const _beatChecker = TypeChecker.fromRuntime(Beat);

List<DartObject> _beatAnnotations(Element element) =>
    _beatChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> beatAnnotations(Element element) =>
    _beatAnnotations(element).map((e) => ConstantReader(e)).toList();
