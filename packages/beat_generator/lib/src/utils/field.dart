import 'package:source_gen/source_gen.dart';

String getFieldValueAsString(ConstantReader reader) {
  if (reader.isLiteral) {
    return reader.literalValue.toString();
  }
  return reader.objectValue.getField('_name')!.toStringValue()!;
}

String getFunctionName(ConstantReader? reader) {
  if (reader == null) {
    return '';
  }
  final parName = reader.objectValue.toString().split(' ').last;
  return parName.substring(1, parName.length - 1);
}

String? getFieldType(ConstantReader? reader) {
  if (reader == null) {
    return null;
  }
  return reader.objectValue.toString().split(' ').first;
}

String? getFieldValue(ConstantReader? reader) {
  if (reader == null) {
    return null;
  }
  return reader.objectValue.toString().split(' ').last;
}
