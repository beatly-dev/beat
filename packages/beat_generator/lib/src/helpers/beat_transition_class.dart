import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../utils/create_class.dart';
import '../utils/string.dart';
import 'execute_actions.dart';

class BeatTransitionClassBuilder {
  BeatTransitionClassBuilder({
    required this.beats,
    required this.commonBeats,
    required this.contextType,
    required this.baseEnum,
  }) {
    baseName = baseEnum.name;
    beatStateClassName = toBeatStateClassName(baseName);
    beatStationClassName = toBeatStationClassName(baseName);
    enumFields = baseEnum.fields
        .where((element) => element.isEnumConstant)
        .map((field) => field.name)
        .toList();
  }

  final ClassElement baseEnum;
  final String contextType;

  late final List<String> enumFields;
  late final String baseName;
  late final String beatStationClassName;
  late final String beatStateClassName;

  final Map<String, List<BeatConfig>> beats;
  final List<BeatConfig> commonBeats;
  final buffer = StringBuffer();

  String build() {
    _createBaseClass();
    _createRealClass();
    _createDummyClass();
    return buffer.toString();
  }

  void _createBaseClass() {
    for (final state in enumFields) {
      final className = toBeatTransitionBaseClassName(baseName, state);
      final body = StringBuffer();

      final beatConfigs = beats[state] ?? [];

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

  void _createRealClass() {
    for (final state in enumFields) {
      final className = toBeatTransitionRealClassName(baseName, state);
      final baseClassName = toBeatTransitionBaseClassName(baseName, state);
      final beatConfigs = beats[state] ?? [];
      final body = StringBuffer();
      if (beatConfigs.isNotEmpty) {
        body.writeln(
          '''
  const $className(this._beatStation);
  final $beatStationClassName _beatStation;
  ''',
        );
      }

      for (final config in beatConfigs) {
        body.writeln(
          '''
void _exec${toBeginningOfSentenceCase(config.event)}Actions(EventData eventData) {
  for (final action in ${toBeatActionVariableName(config.fromField, config.event, config.toField)}.actions) {
    ${ActionExecutorBuilder(
            actionName: 'action',
            baseName: baseName,
            contextType: contextType,
            eventData: 'eventData',
            isStation: false,
          ).build()}
  }
}
''',
        );
        body.writeln(
          '''
@override
void \$${config.event}<Data>([Data? data]) {
  _exec${toBeginningOfSentenceCase(config.event)}Actions(EventData(
    event: '${config.event}',
    data: data,
  ));
  _beatStation._setState($baseName.${config.toField});
}
''',
        );
      }
      buffer.writeln(
        createClass('$className extends $baseClassName', body.toString()),
      );
    }
  }

  void _createDummyClass() {
    for (final state in enumFields) {
      final className = toBeatTransitionDummyClassName(baseName, state);
      final baseClassName = toBeatTransitionBaseClassName(baseName, state);
      final body = StringBuffer();

      final beatConfigs = beats[state] ?? [];

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
