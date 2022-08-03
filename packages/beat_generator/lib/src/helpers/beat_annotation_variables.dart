import 'package:beat_config/beat_config.dart';

import '../utils/string.dart';

class BeatAnnotationVariablesBuilder {
  final List<BeatConfig> beats;

  BeatAnnotationVariablesBuilder(this.beats);

  String build() {
    StringBuffer buffer = StringBuffer();
    for (final beat in beats) {
      final decl = toBeatActionVariableDeclaration(
        beat.fromField,
        beat.event,
        beat.toField,
        beat.source,
      );
      buffer.writeln(decl);
    }
    return buffer.toString();
  }
}
