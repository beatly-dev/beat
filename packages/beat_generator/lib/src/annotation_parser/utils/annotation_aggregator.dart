import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class AggregatedAnnotation {
  final ElementAnnotation elementAnnotation;
  final DartObject annotationObj;
  final ConstantReader annotation;
  final Element element;
  final String source;

  AggregatedAnnotation({
    required this.elementAnnotation,
    required this.annotationObj,
    required this.annotation,
    required this.element,
    required this.source,
  });
}

List<AggregatedAnnotation> aggregateAnnotations(
  Element element,
  TypeChecker typeChecker,
  BuildStep buildStep,
) {
  final fields = (element is ClassElement) ? element.fields : [];
  final annotations = getAnnotations(element, typeChecker, buildStep);
  for (final field in fields) {
    annotations.addAll(
      getAnnotations(field, typeChecker, buildStep),
    );
  }
  return annotations;
}

List<AggregatedAnnotation> getAnnotations<C>(
  Element element,
  TypeChecker typeChecker,
  BuildStep buildStep,
) {
  final annotations = <AggregatedAnnotation>[];
  for (final annotationElm in element.metadata) {
    final annotationObj = annotationElm.computeConstantValue();

    if (annotationObj == null) continue;
    final type = annotationObj.type!;
    if (!typeChecker.isAssignableFromType(type)) {
      continue;
    }
    final source = annotationElm.toSource().substring(1);
    final annotation = ConstantReader(annotationObj);

    annotations.add(
      AggregatedAnnotation(
        elementAnnotation: annotationElm,
        annotationObj: annotationObj,
        annotation: annotation,
        element: element,
        source: source,
      ),
    );
  }

  return annotations;
}
