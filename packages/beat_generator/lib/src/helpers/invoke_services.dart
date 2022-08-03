import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../utils/string.dart';

class InvokeServicesBuilder {
  InvokeServicesBuilder({
    required this.invokes,
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
  final Map<String, List<InvokeConfig>> invokes;
  final buffer = StringBuffer();

  String build() {
    for (var state in invokes.keys) {
      final configs = invokes[state];
      for (var config in configs!) {
        buffer.writeln(toInvokeVariableDeclaration(config));
      }
    }

    return buffer.toString();
  }
}
