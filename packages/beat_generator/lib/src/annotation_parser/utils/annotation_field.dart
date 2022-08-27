import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

String getAnnotationEnumFieldValue(ConstantReader reader, String fieldName) {
  final element = getElementForField(reader, fieldName);
  if (element == null || element is! EnumElement) {
    throw Exception('Expected field $fieldName to be a Enum value');
  }
  final field = reader.read(fieldName);
  return field.read('_name').stringValue;
}

String getAnnotationEnumFieldClass(ConstantReader reader, String fieldName) {
  final element = getElementForField(reader, fieldName);
  if (element == null || element is! EnumElement) {
    throw Exception('Expected field $fieldName to be a Enum value');
  }
  return element.displayName;
}

String getAnnotationFieldLiteralValue(ConstantReader reader, String fieldName) {
  final field = reader.read(fieldName);
  if (field.isLiteral) {
    return field.literalValue!.toString();
  }
  return field.objectValue.toString();
}

ClassElement? getElementForField(ConstantReader reader, String fieldName) {
  final field = reader.read(fieldName);
  final element = getElementFromConstantReader(field);
  return element;
}

ClassElement? getElementFromConstantReader(ConstantReader reader) {
  final object = reader.objectValue;
  return object.type?.element2 as ClassElement?;
}
