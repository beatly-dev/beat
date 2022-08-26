import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'string.dart';

String? getListField(String source, String fieldName) {
  final matches = RegExp('$fieldName\\s*:\\s*(\\[.*?\\])').firstMatch(source);
  final list = matches?.group(matches.groupCount);
  if (list == null) return null;
  return firstMatchingList(list);
}

String? getDurationSource(String source, String fieldName) {
  final start = source.split(fieldName);
  if (start.length < 2) return null;
  final right = start[1];
  final durationStart = right.indexOf('Duration');
  if (durationStart != -1) {
    var parCount = 0;
    for (var i = durationStart; i < right.length; ++i) {
      final char = right[i];
      if (char == '(') {
        parCount++;
      } else if (char == ')') {
        parCount--;
        if (parCount == 0) {
          return right.substring(durationStart, i + 1);
        }
      }
    }
  }

  final comma = right.split(',');
  if (comma.isNotEmpty) return comma[0];
  final par = right.split(')');
  if (par.isNotEmpty) return par[0];
  return null;
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
