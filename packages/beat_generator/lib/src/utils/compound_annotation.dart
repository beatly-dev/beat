import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:source_gen/source_gen.dart';

import '../models/compound_config.dart';

Future<Map<String, List<CompoundConfig>>> mapCompoundAnnotations<C>(
  String stateName,
  List<Element> fields,
) async {
  final compounds = <String, List<CompoundConfig>>{};
  for (final field in fields) {
    final compoundConfigs =
        await mapCommonCompoundAnnotations(stateName, field);
    final from = field.name!;
    compounds[from] = compoundConfigs;
  }
  return compounds;
}

Future<List<CompoundConfig>> mapCommonCompoundAnnotations<C>(
  String parentBase,
  Element field,
) async {
  final compoundConfigs = <CompoundConfig>[];
  final parent = field.name ?? '';
  for (final annotationElm in field.metadata) {
    final annotationObj = annotationElm.computeConstantValue();
    if (annotationObj == null) continue;
    final type = annotationObj.type!;
    if (!_compoundChecker.isAssignableFromType(type)) {
      continue;
    }
    final annotationReader = ConstantReader(annotationObj);
    final source = annotationElm.toSource().substring(1);
    final child = annotationReader
        .read('child')
        .typeValue
        .getDisplayString(withNullability: false);
    final childEnum =
        annotationReader.read('child').typeValue.element! as ClassElement;
    final enumField = childEnum.fields.where(
      (field) => field.isEnumConstant,
    );
    final firstFieldName = enumField.isNotEmpty ? enumField.first.name : '';

    final config = CompoundConfig(
      parentBase: parentBase,
      parent: parent,
      childBase: child,
      childFirst: firstFieldName,
      source: source,
    );
    compoundConfigs.add(config);
  }

  return compoundConfigs;
}

const _compoundChecker = TypeChecker.fromRuntime(Compound);

List<DartObject> _compoundAnnotations(Element element) =>
    _compoundChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> compoundAnnotations(Element element) =>
    _compoundAnnotations(element).map((e) => ConstantReader(e)).toList();
