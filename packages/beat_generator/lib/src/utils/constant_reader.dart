import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'string.dart';

String? getListField(String source, String fieldName) {
  final matches = RegExp('$fieldName\\s*:\\s*(\\[.*?\\])').firstMatch(source);
  final list = matches?.group(matches.groupCount);
  if (list == null) return null;
  return firstMatchingList(list);
}

String? getTypeField(ConstantReader reader, String fieldName) {
  return reader
      .read(fieldName)
      .typeValue
      .getDisplayString(withNullability: false);
}

String getFirstFieldOfEnum(ConstantReader reader, String fieldName) {
  final enumField = reader.read(fieldName);
  final element = enumField.typeValue.element2;
  if (element is! ClassElement || element is! EnumElement) {
    throw 'Expected enum type for $fieldName';
  }
  final fieldLength = element.fields.length;
  if (fieldLength == 0) {
    throw 'Empty enum is omitted';
  }
  final firstField =
      element.fields.firstWhere((element) => element.isEnumConstant);
  return firstField.displayName;
}
