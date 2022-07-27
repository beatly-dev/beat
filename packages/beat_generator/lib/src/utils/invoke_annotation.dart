import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:source_gen/source_gen.dart';

import '../models/invoke_config.dart';

Future<Map<String, List<InvokeConfig>>> mapInvokeAnnotations<C>(
  String stateName,
  List<Element> fields,
) async {
  final invokes = <String, List<InvokeConfig>>{};
  for (final field in fields) {
    final invokeConfigs = await mapCommonInvokeAnnotations(stateName, field);
    final from = field.name!;
    invokes[from] = invokeConfigs;
  }
  return invokes;
}

Future<List<InvokeConfig>> mapCommonInvokeAnnotations<C>(
  String stateName,
  Element field,
) async {
  final invokeConfigs = <InvokeConfig>[];
  final on = field.name ?? '';
  for (final annotationElm in field.metadata) {
    final annotationObj = annotationElm.computeConstantValue();
    if (annotationObj == null) continue;
    final type = annotationObj.type!;
    if (!_invokeChecker.isAssignableFromType(type)) {
      continue;
    }
    final source = annotationElm.toSource().substring(1);

    final config = InvokeConfig(stateName: stateName, on: on, source: source);
    invokeConfigs.add(config);
  }

  return invokeConfigs;
}

const _invokeChecker = TypeChecker.fromRuntime(Invokes);

List<DartObject> _invokeAnnotations(Element element) =>
    _invokeChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> beatAnnotations(Element element) =>
    _invokeAnnotations(element).map((e) => ConstantReader(e)).toList();
