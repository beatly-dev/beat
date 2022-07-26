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
    for (final state in enumFields) {
      final className = toBeatTransitionClassName(state);
      final body = StringBuffer();
      body.writeln(
        '''
  $className(this._beatStation);
  final $beatStationClassName _beatStation;
  ''',
      );

      final beatConfigs = beats[state] ?? [];

      for (final config in beatConfigs) {
        body.writeln(
          '''
void \$${config.event}() {
  _beatStation._setState($baseName.${config.to});
}
''',
        );
      }
      buffer.writeln(createClass(className, body.toString()));
    }
    return buffer.toString();
  }
}
