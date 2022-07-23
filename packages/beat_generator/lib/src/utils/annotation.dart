import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:source_gen/source_gen.dart';

import '../models/beat_config.dart';
import 'field.dart';
import 'string.dart';

Future<Map<String, List<BeatConfig>>> mapBeatAnnotations<C>(
  String stateName,
  List<Element> fields,
) async {
  final beats = <String, List<BeatConfig>>{};
  for (final field in fields) {
    final beatConfigs = await mapCommonBeatAnnotations(stateName, field);
    final from = field.name!;
    beats[from] = beatConfigs;
  }
  return beats;
}

Future<List<BeatConfig>> mapCommonBeatAnnotations<C>(
  String stateName,
  Element field,
) async {
  final beatConfigs = <BeatConfig>[];
  final from = field.name ?? '';
  for (final annotationElm in field.metadata) {
    final annotationObj = annotationElm.computeConstantValue();
    if (annotationObj == null) continue;
    final type = annotationObj.type!;
    if (!_beatChecker.isAssignableFromType(type)) {
      continue;
    }
    final source = annotationElm.toSource();

    final annotation = ConstantReader(annotationObj);
    final eventField = annotation.read('event');
    final toField = annotation.read('to');

    String event = getFieldValueAsString(eventField);
    String to = getFieldValueAsString(toField);
    final config = BeatConfig(
      from: from,
      event: event,
      to: to,
      source: source,
    );
    beatConfigs.add(config);
  }

  return beatConfigs;
}

const _beatChecker = TypeChecker.fromRuntime(Beat);

List<DartObject> _beatAnnotations(Element element) =>
    _beatChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> beatAnnotations(Element element) =>
    _beatAnnotations(element).map((e) => ConstantReader(e)).toList();

String toBeatVariableName(String from, String event, String to) =>
    '_${toDartFieldCase(event)}From${toBeginningOfSentenceCase(from)}To${toBeginningOfSentenceCase(to)}';

String toBeatVariableDeclaration(
  String from,
  String event,
  String to,
  String source,
) =>
    'const ${toBeatVariableName(from, event, to)} = ${source.substring(1)};';
