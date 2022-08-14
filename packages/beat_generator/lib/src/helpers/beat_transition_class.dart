import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../constants/field_names.dart';
import '../resources/beat_tree_resource.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';
import 'execute_actions.dart';

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
void \$${config.event}<Data>([Data? data]);
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
  const $className(this._beatStation);
  final $beatStationClassName _beatStation;
  ''',
        );
      }

      for (final config in beatConfigs) {
        /// action executors
        body.writeln(
          '''
void ${toActionExecutorMethodName(config.event)}(EventData eventData) {
  for (final action in ${toBeatAnnotationVariableName(config.fromBase, config.fromField, config.event, config.toBase, config.toField)}.actions) {
    ${createActionExecutor('action', 'eventData', false)}
  }
}
''',
        );

        /// transition method
        body.writeln(
          '''
@override
void \$${config.event}<Data>([Data? data]) {
  // if the station is not started (when it's substation), do nothing
  if (!_beatStation.$stationStartedFieldName) {
    return ;
  }
  ${toActionExecutorMethodName(config.event)}(EventData(
    event: '${config.event}',
    data: data,
  ));
  _beatStation.$setStateMethodName(${config.toBase}.${config.toField});
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
void \$${config.event}<Data>([Data? data]) {}
''',
        );
      }
      buffer.writeln(
        createClass('$className extends $baseClassName', body.toString()),
      );
    }
  }
}
