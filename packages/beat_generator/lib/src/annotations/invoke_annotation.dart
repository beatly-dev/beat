import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation_aggregator.dart';

Future<List<InvokeConfig>> aggregateInvokeConfigs(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) async {
  final annotations =
      await aggregateAnnotations(element, _invokeChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) {
    final fromField = e.element.name!;
    final source = e.source;

    final config = InvokeConfig(
      stateBase: fromBase!,
      stateField: fromField,
      source: source,
    );
    return config;
  }).toList();
}

Future<List<InvokeConfig>> getInvokeAnnotations(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) async {
  final annotations = await getAnnotations(element, _invokeChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) {
    final fromField = e.element.name!;
    final source = e.source;

    final config = InvokeConfig(
      stateBase: fromBase!,
      stateField: fromField,
      source: source,
    );
    return config;
  }).toList();
}

Future<Map<String, List<InvokeConfig>>> mapInvokeAnnotations(
  String stateName,
  List<Element> fields,
  BuildStep buildStep,
) async {
  final invokes = <String, List<InvokeConfig>>{};
  for (final field in fields) {
    if (field is! ClassElement &&
        !(field is FieldElement && field.isEnumConstant)) {
      continue;
    }
    final invokeConfigs =
        await getInvokeAnnotations(field, stateName, buildStep);
    final from = field.name!;
    invokes[from] = invokeConfigs;
  }
  return invokes;
}

const _invokeChecker = TypeChecker.fromRuntime(Invokes);

List<DartObject> _invokeAnnotations(Element element) =>
    _invokeChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> invokeAnnotations(Element element) =>
    _invokeAnnotations(element).map((e) => ConstantReader(e)).toList();
