import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation_aggregator.dart';

List<ServiceConfig> aggregateInvokeConfigs(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) {
  final annotations =
      aggregateAnnotations(element, _servicesChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) {
    final fromField = e.element.name!;
    final source = e.source;

    final config = ServiceConfig(
      stateBase: fromBase!,
      stateField: fromField,
      source: source,
    );
    return config;
  }).toList();
}

List<ServiceConfig> getInvokeAnnotations(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) {
  final annotations = getAnnotations(element, _servicesChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) {
    final fromField = e.element.name!;
    final source = e.source;

    final config = ServiceConfig(
      stateBase: fromBase!,
      stateField: fromField,
      source: source,
    );
    return config;
  }).toList();
}

Map<String, List<ServiceConfig>> mapInvokeAnnotations(
  String stateName,
  List<Element> fields,
  BuildStep buildStep,
) {
  final invokes = <String, List<ServiceConfig>>{};
  for (final field in fields) {
    if (field is! ClassElement &&
        !(field is FieldElement && field.isEnumConstant)) {
      continue;
    }
    final invokeConfigs = getInvokeAnnotations(field, stateName, buildStep);
    final from = field.name!;
    invokes[from] = invokeConfigs;
  }
  return invokes;
}

const _servicesChecker = TypeChecker.fromRuntime(Services);

List<DartObject> _servicesAnnotations(Element element) =>
    _servicesChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> servicesAnnotations(Element element) =>
    _servicesAnnotations(element).map((e) => ConstantReader(e)).toList();
