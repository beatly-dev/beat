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
    final onDemandDecl = RegExp(r'^Beat.*\(');
    for (final beat in beats) {
      var decl =
          'const ${toBeatAnnotationVariableName(beat.fromBase, beat.fromField, beat.event, beat.toBase, beat.toField)} = ${beat.source};';
      if (onDemandDecl.hasMatch(beat.source)) {
        decl = toBeatAnnotationVariableDeclaration(beat);
      }
      buffer.writeln(decl);
    }
    return buffer.toString();
  }
}
