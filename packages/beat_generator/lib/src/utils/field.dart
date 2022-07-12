import 'package:source_gen/source_gen.dart';

String getFieldValueAsString(ConstantReader reader) {
  if (reader.isLiteral) {
    return reader.literalValue.toString();
  }
  return reader.objectValue.getField('_name')!.toStringValue()!;
}
