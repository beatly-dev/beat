import 'package:analyzer/dart/element/element.dart';

import '../resources/beat_tree_resource.dart';
import '../utils/string.dart';

class GlobalInovkeAnnotationVariablesBuilder {
  GlobalInovkeAnnotationVariablesBuilder({
    required this.baseEnum,
    required this.beatTree,
  });

  final ClassElement baseEnum;
  final BeatTreeSharedResource beatTree;

  Future<String> build() async {
    final buffer = StringBuffer();
    final baseName = baseEnum.name;
    final beatNode = beatTree.getNode(baseName);
    final invokes = beatNode.invokeConfigs.values.expand((element) => element);
    for (final invoke in invokes) {
      buffer.writeln(toInvokeVariableDeclaration(invoke));
    }

    return buffer.toString();
  }
}
