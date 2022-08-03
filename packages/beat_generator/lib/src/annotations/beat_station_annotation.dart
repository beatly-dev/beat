import 'package:source_gen/source_gen.dart';

import '../utils/constant_reader.dart';

String getBeatStationContextType(ConstantReader annotation) {
  return getTypeField(annotation, 'contextType')!;
}
