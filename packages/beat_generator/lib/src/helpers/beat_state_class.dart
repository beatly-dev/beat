import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../constants/field_names.dart';
import '../resources/beat_tree_resource.dart';
import '../utils/context.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';

class BeatStateBuilder {
  BeatStateBuilder({
    required this.baseEnum,
    required this.beatTree,
  });

  final ClassElement baseEnum;
  final BeatTreeSharedResource beatTree;

  Future<String> build() async {
    final relatedStations = await beatTree.getRelatedStations(baseEnum.name);
    final beatStateClassName = toBeatStateClassName(baseEnum.name);
    final node = beatTree.getNode(baseEnum.name);
    final providedContextType = node.info.contextType;
    final contextType = toContextType(providedContextType);
    final body = [
      _createFinalFieldsAndConstructor(),
      _creatMatcher(relatedStations),
    ].join();
    return createClass(
      '$beatStateClassName extends BaseBeatState<$contextType>',
      body,
    );
  }

  String _createFinalFieldsAndConstructor() {
    final beatStateClassName = toBeatStateClassName(baseEnum.name);
    final node = beatTree.getNode(baseEnum.name);
    final providedContextType = node.info.contextType;
    final contextType = toContextType(providedContextType);

    final constructor = StringBuffer();
    final finalFields = StringBuffer();

    constructor.writeln('$beatStateClassName({');
    constructor.writeln('required Enum state,');
    constructor.writeln('$contextType context,');
    constructor.writeln('}): super(state, context);');

    return '''
${constructor.toString()}
${finalFields.toString()}
''';
  }

  String _creatMatcher(List<BeatStationNode> nodes) {
    final states = nodes.map((node) {
      final baseEnumName = node.info.baseEnumName;
      return node.info.states.map((state) => _State(baseEnumName, state));
    }).expand((states) => states);

    final buffer = StringBuffer();
    for (final state in states) {
      buffer.writeln(
        'bool get is${state.baseName}${toBeginningOfSentenceCase(state.fieldName)} {',
      );
      buffer.writeln(
        '''
return $stateFieldName == ${state.baseName}.${state.fieldName};
''',
      );
      buffer.writeln('}');
    }
    return buffer.toString();
  }
}

String toPrivateFieldName(String stationName) =>
    '_${toDartFieldCase(stationName)}';

class _State {
  final String baseName;
  final String fieldName;

  _State(this.baseName, this.fieldName);
}

class ClassField {
  final String name;
  final String type;

  ClassField(this.name, this.type);
}
