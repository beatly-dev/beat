import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../utils/constant_reader.dart';
import 'annotation_aggregator.dart';

Future<List<SubstationConfig>> aggregateSubstationConfigs(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) async {
  final annotations =
      await aggregateAnnotations(element, _substationChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) {
    final annotation = e.annotation;
    final fromField = e.element.name!;
    final childBase = getTypeField(annotation, 'child')!;
    final childFirst = getFirstFieldOfEnum(annotation, 'child');
    final source = e.source;
    if (fromBase == childBase) {
      throw 'Prohibited: self referencing substation $fromBase';
    }

    final config = SubstationConfig(
      parentBase: fromBase!,
      parentField: fromField,
      childBase: childBase,
      childFirst: childFirst,
      source: source,
    );
    return config;
  }).toList();
}

Future<List<SubstationConfig>> getSubstationConfigs(
  Element element,
  String? fromBase,
  BuildStep buildStep,
) async {
  final annotations =
      await getAnnotations(element, _substationChecker, buildStep);
  fromBase ??= element.name;
  return annotations.map((e) {
    final annotation = e.annotation;
    final fromField = e.element.name!;
    final childBase = getTypeField(annotation, 'child')!;
    final childFirst = getFirstFieldOfEnum(annotation, 'child');
    final source = e.source;
    if (fromBase == childBase) {
      throw 'Prohibited: self referencing substation $fromBase';
    }

    final config = SubstationConfig(
      parentBase: fromBase!,
      parentField: fromField,
      childBase: childBase,
      childFirst: childFirst,
      source: source,
    );
    return config;
  }).toList();
}

Future<Map<String, List<SubstationConfig>>> mapSubstationAnnotations<C>(
  String stateName,
  List<Element> fields,
  BuildStep buildStep,
) async {
  final substations = <String, List<SubstationConfig>>{};
  for (final field in fields) {
    final substationConfigs =
        await getSubstationConfigs(field, stateName, buildStep);
    final from = field.name!;
    substations[from] = substationConfigs;
  }
  return substations;
}

const _substationChecker = TypeChecker.fromRuntime(Substation);

List<DartObject> _substationAnnotations(Element element) => _substationChecker
    .annotationsOf(element, throwOnUnresolved: false)
    .toList();

List<ConstantReader> substationAnnotations(Element element) =>
    _substationAnnotations(element).map((e) => ConstantReader(e)).toList();
