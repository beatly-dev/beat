import 'package:analyzer/dart/element/element.dart';

import '../models/beat_config.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';

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
      final className = toBeatTransitionBaseClassName(state);
      final body = StringBuffer();

      final beatConfigs = beats[state] ?? [];

      for (final config in beatConfigs) {
        body.writeln(
          '''
void \$${config.event}();
''',
        );
      }
      buffer.writeln(createClass(className, body.toString(), isAbstract: true));
    }
  }

  void _createRealClass() {
    for (final state in enumFields) {
      final className = toBeatTransitionRealClassName(state);
      final baseClassName = toBeatTransitionBaseClassName(state);
      final beatConfigs = beats[state] ?? [];
      final body = StringBuffer();
      if (beatConfigs.isNotEmpty) {
        body.writeln(
          '''
  $className(this._beatStation);
  final $beatStationClassName _beatStation;
  ''',
        );
      }

      for (final config in beatConfigs) {
        body.writeln(
          '''
void exec${toBeginningOfSentenceCase(config.event)}Actions() {
  for (final action in ${toBeatActionVariableName(config.from, config.event, config.to)}.actions) {
    if (action is DefaultAction) {
      action.execute(_beatStation.currentState.state, _beatStation.currentState.context, '${config.event}');
    }
  }
}
''',
        );
        body.writeln(
          '''
@override
void \$${config.event}() {
  exec${toBeginningOfSentenceCase(config.event)}Actions();
  _beatStation._setState($baseName.${config.to});
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
      final className = toBeatTransitionDummyClassName(state);
      final baseClassName = toBeatTransitionBaseClassName(state);
      final body = StringBuffer();

      final beatConfigs = beats[state] ?? [];

      for (final config in beatConfigs) {
        body.writeln(
          '''
@override
void \$${config.event}() {}
''',
        );
      }
      buffer.writeln(
        createClass('$className extends $baseClassName', body.toString()),
      );
    }
  }
}