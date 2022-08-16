import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../constants/field_names.dart';
import '../resources/beat_tree_resource.dart';
import '../utils/context.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';

/// TODO:
/// support required context parameter.
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
      '$beatStateClassName extends BeatState<${baseEnum.name}, $contextType>',
      body,
    );
  }

  String _createFinalFieldsAndConstructor() {
    final beatStateClassName = toBeatStateClassName(baseEnum.name);
    final node = beatTree.getNode(baseEnum.name);
    final childKeys = node.children.keys;
    final providedContextType = node.info.contextType;
    final contextType = toContextType(providedContextType);

    final constructor = StringBuffer();
    final finalFields = StringBuffer();
    final initializer = StringBuffer();
    finalFields.writeln(
      '''
late final ${toBeatStationClassName(baseEnum.name)} _station;
''',
    );

    constructor.writeln(
      '''$beatStateClassName({''',
    );
    constructor.writeln('required ${node.info.baseEnumName} state,');
    constructor.writeln('$contextType context,');
    constructor.writeln('}): super(state, context);');

    initializer.writeln(
      '''
$stateInitializerMethodName(${toBeatStationClassName(baseEnum.name)} station) {
  _station = station;
}
''',
    );

    final hasSubstate = childKeys
        .map(
          (state) => '''
  ${toStateMatcher(node.info.baseEnumName, state, node.info.baseEnumName == baseEnum.name)}
''',
        )
        .join(' || ');

    return '''
${constructor.toString()}
${finalFields.toString()}
${initializer.toString()}

@override
bool get hasSubstate => ${childKeys.isEmpty ? 'false' : hasSubstate};
''';
  }

  String _creatMatcher(List<BeatStationNode> nodes) {
    final rootEnumName = baseEnum.name;
    final states = nodes.map((node) {
      final baseEnumName = node.info.baseEnumName;
      return node.info.states.map((state) => _State(baseEnumName, state));
    }).expand((states) => states);

    /// TODO:
    /// 1. If a user asks for a substate => done
    /// 2. If a user asks for a parallel state => not yet supported
    final buffer = StringBuffer();
    for (final state in states) {
      buffer.writeln(
        'bool get ${toStateMatcher(state.baseName, state.fieldName, rootEnumName == state.baseName)} {',
      );
      if (rootEnumName != state.baseName) {
        /// last level (leaf) node state matcher
        final leafChecker =
            '_station.${beatTree.substationRouteBetween(from: rootEnumName, to: state.baseName)}.currentState.${toStateMatcher(state.baseName, state.fieldName, true)}';

        /// root to parent of the leaf matcher
        final route =
            beatTree.routeBetween(from: rootEnumName, to: state.baseName);
        final pathChecker = route.map((node) {
          final parentBase = node.parentBase;
          final parentField = node.parentField;
          if (parentBase == rootEnumName) {
            return '''
 _station.currentState.${toStateMatcher(parentBase, parentField, true)} 
''';
          } else {
            return '''
 _station.${beatTree.substationRouteBetween(from: rootEnumName, to: parentBase)}.currentState.${toStateMatcher(parentBase, parentField, true)} 
''';
          }
        }).join(' && ');
        buffer.writeln(
          'return $pathChecker && $leafChecker; ',
        );
      } else {
        buffer.writeln(
          '''
return $stateFieldName == ${state.baseName}.${state.fieldName};
''',
        );
      }
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
