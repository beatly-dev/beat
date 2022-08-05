import 'package:analyzer/dart/element/element.dart';

import '../resources/beat_tree_resource.dart';
import '../utils/string.dart';

class GlobalBeatAnnotationVariablesBuilder {
  GlobalBeatAnnotationVariablesBuilder({
    required this.beatTree,
    required this.baseEnum,
  });
  final BeatTreeSharedResource beatTree;
  final ClassElement baseEnum;

  Future<String> build() async {
    final baseName = baseEnum.name;
    final beatNode = beatTree.getNode(baseName);
    final beats = beatNode.beatConfigs.values.expand((element) => element);
    StringBuffer buffer = StringBuffer();
    print("Build for $baseName - ${beats.length} beats");
    for (final beat in beats) {
      final decl = toBeatVariableDeclaration(
        beat.fromBase,
        beat.fromField,
        beat.event,
        beat.toBase,
        beat.toField,
        beat.actions,
        beat.conditions,
        beat.eventDataType,
      );
      buffer.writeln(decl);
    }
    return buffer.toString();
  }
}
