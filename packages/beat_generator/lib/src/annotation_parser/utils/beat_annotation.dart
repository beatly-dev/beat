import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../../utils/constant_reader.dart';
import 'annotation_aggregator.dart';
import 'annotation_field.dart';

List<BeatConfig> aggregateBeatConfigs(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) {
  final annotations = aggregateAnnotations(element, _beatChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) => e.toBeatConfig(fromBase!)).toList();
}

List<BeatConfig> getBeatConfigs(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) {
  final annotations = getAnnotations(element, _beatChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) => e.toBeatConfig(fromBase!)).toList();
}

Map<String, List<BeatConfig>> mapBeatAnnotations<C>(
  String stateName,
  List<Element> fields,
  BuildStep buildStep,
) {
  final beats = <String, List<BeatConfig>>{};
  for (final field in fields) {
    if (field is! ClassElement &&
        !(field is FieldElement && field.isEnumConstant)) {
      continue;
    }
    final beatConfigs = getBeatConfigs(field, stateName, buildStep);
    final from = field.name!;
    beats[from] = beatConfigs;
    if (field is ClassElement) {
      final fieldBeats = mapBeatAnnotations(stateName, field.fields, buildStep);
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
const _eventlessBeatChecker = TypeChecker.fromRuntime(EventlessBeat);

List<DartObject> _beatAnnotations(Element element) =>
    _beatChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> beatAnnotations(Element element) =>
    _beatAnnotations(element).map((e) => ConstantReader(e)).toList();

extension on AggregatedAnnotation {
  BeatConfig toBeatConfig(String fromBase) {
    final e = this;
    final annotation = ConstantReader(e.annotationObj);

    final fromField = e.element.name!;
    final toField = getAnnotationEnumFieldValue(annotation, 'to');
    final toBase = getAnnotationEnumFieldClass(annotation, 'to');
    final source = e.source;
    final actions = getBeatActionsField(source);
    final argType = getBeatArgTypeField(annotation);
    final conditions = getBeatConditionsField(source);
    var event = getAnnotationFieldLiteralValue(annotation, 'event').trim();
    final blankRegexp = RegExp(r'\s+(\w)');
    final blankMatches = blankRegexp.allMatches(event);
    for (final match in blankMatches) {
      final firstChar = match.group(match.groupCount)!.toUpperCase();
      final start = match.start;
      final end = match.end;
      event = event.replaceRange(start, end, firstChar);
    }

    final specialRegexp = RegExp(r'[^a-zA-Z0-9]');
    event = event.replaceAll(specialRegexp, '');

    final type = e.annotationObj.type!;
    var eventless = false;
    var after = 'const Duration(milliseconds: 0)';

    if (_eventlessBeatChecker.isAssignableFromType(type)) {
      eventless = true;
      after = getDurationSource(e.source, 'after') ?? after;
    }

    final config = BeatConfig(
      fromBase: fromBase,
      fromField: fromField,
      event: event,
      toBase: toBase,
      toField: toField,
      source: source,
      actions: actions,
      eventDataType: argType,
      conditions: conditions,
      eventless: eventless,
      after: after,
    );
    return config;
  }
}
