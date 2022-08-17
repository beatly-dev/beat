import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../resources/beat_tree_resource.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';

/// TODO:
/// Support explicitly defined event data type.
class BeatTransitionClassBuilder {
  BeatTransitionClassBuilder({
    required this.baseEnum,
    required this.beatTree,
  });

  final ClassElement baseEnum;
  final BeatTreeSharedResource beatTree;
  final buffer = StringBuffer();

  Future<String> build() async {
    final node = beatTree.getNode(baseEnum.name);
    _createBaseClass(node);
    _createRealClass(node);
    _createDummyClass(node);
    return buffer.toString();
  }

  void _createBaseClass(BeatStationNode node) {
    final baseName = baseEnum.name;
    for (final state in node.info.states) {
      final className = toBeatTransitionBaseClassName(baseName, state);
      final body = StringBuffer();

      final beatConfigs = (node.beatConfigs[state] ?? [])
          .where((element) => !element.eventless);

      body.writeln('const $className();');
      for (final config in beatConfigs) {
        body.writeln(
          '''
void \$${config.event}<Data>({Data? data, Duration after = const Duration(milliseconds: 0)});
''',
        );
      }
      buffer.writeln(createClass(className, body.toString(), isAbstract: true));
    }
  }

  void _createRealClass(BeatStationNode node) {
    final baseName = baseEnum.name;
    final beatStationClassName = toBeatStationClassName(baseName);
    for (final state in node.info.states) {
      final className = toBeatTransitionRealClassName(baseName, state);
      final baseClassName = toBeatTransitionBaseClassName(baseName, state);
      final beatConfigs = (node.beatConfigs[state] ?? [])
          .where((element) => !element.eventless);
      final body = StringBuffer();
      if (beatConfigs.isNotEmpty) {
        /// constructor and parent beat station;
        body.writeln(
          '''
  const $className(this._station);
  final $beatStationClassName _station;
  ''',
        );
      }

      for (final config in beatConfigs) {
        final beatAnnotation = toBeatAnnotationVariableName(
          config.fromBase,
          config.fromField,
          config.event,
          config.toBase,
          config.toField,
        );

        /// transition method
        body.writeln(
          '''
@override
\$${config.event}<Data>({Data? data, Duration after = const Duration(milliseconds: 0)}) {
  _station.triggerTransitions($beatAnnotation, data, after);
}
''',
        );
      }
      buffer.writeln(
        createClass('$className extends $baseClassName', body.toString()),
      );
    }
  }

  void _createDummyClass(BeatStationNode node) {
    final baseName = baseEnum.name;
    for (final state in node.info.states) {
      final className = toBeatTransitionDummyClassName(baseName, state);
      final baseClassName = toBeatTransitionBaseClassName(baseName, state);
      final body = StringBuffer();

      final beatConfigs = (node.beatConfigs[state] ?? [])
          .where((element) => !element.eventless);

      body.writeln('const $className();');
      for (final config in beatConfigs) {
        body.writeln(
          '''
@override
void \$${config.event}<Data>({Data? data, Duration after = const Duration(milliseconds: 0)}) {}
''',
        );
      }
      buffer.writeln(
        createClass('$className extends $baseClassName', body.toString()),
      );
    }
  }
}
