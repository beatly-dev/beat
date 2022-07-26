import 'package:analyzer/dart/element/element.dart';

import '../utils/context.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';

class BeatStateBuilder {
  BeatStateBuilder({
    required this.contextType,
    required this.baseEnum,
  }) {
    baseName = baseEnum.name;
    beatStateClassName = toBeatStateClassName(baseName);
    beatStationClassName = toBeatStationClassName(baseName);
  }

  final ClassElement baseEnum;
  final String contextType;
  late final String baseName;
  late final String beatStationClassName;
  late final String beatStateClassName;
  final buffer = StringBuffer();

  String build() {
    final contextType =
        isNullContextType(this.contextType) ? 'dynamic' : this.contextType;

    return createClass(
      beatStateClassName,
      '''
  $beatStateClassName({
    required this.state,
    ${isNullableContextType(contextType) ? '' : 'required'} this.context,
  });
  final $baseName state;
  final $contextType context;

  @override
  String toString() => '$beatStateClassName(state: \$state, context: \$context)';
''',
    );
  }
}