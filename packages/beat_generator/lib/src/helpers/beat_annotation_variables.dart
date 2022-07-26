import '../models/beat_config.dart';
import '../utils/string.dart';

class BeatAnnotationVariablesBuilder {
  final List<BeatConfig> beats;

  BeatAnnotationVariablesBuilder(this.beats);

  String build() {
    StringBuffer buffer = StringBuffer();
    for (final beat in beats) {
      final decl = toBeatActionVariableDeclaration(
        beat.from,
        beat.event,
        beat.to,
        beat.source,
      );
      print(decl);
      buffer.writeln(decl);
    }
    return buffer.toString();
  }
}
