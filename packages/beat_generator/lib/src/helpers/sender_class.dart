import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../constants/field_names.dart';
import '../resources/beat_tree_resource.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';

class SenderClassBuilder {
  SenderClassBuilder({
    required this.baseEnum,
    required this.beatTree,
  });
  final ClassElement baseEnum;
  final BeatTreeSharedResource beatTree;

  Future<String> build() async {
    final enumName = baseEnum.name;
    final senderClassName = toBeatSenderClassName(enumName);
    final relatedStations = await beatTree.getRelatedStations(enumName);
    final events = _gatherByEvents(relatedStations);
    final body = [
      _createConstructor(),
      _createSender(events),
    ];
    return createClass(senderClassName, body.join());
  }

  String _createConstructor() {
    final senderClassName = toBeatSenderClassName(baseEnum.name);
    final baseName = baseEnum.name;
    return '''
$senderClassName(this._station);
final ${toBeatStationClassName(baseName)} _station;
''';
  }

  Map<String, List<BeatConfig>> _gatherByEvents(List<BeatStationNode> nodes) {
    final events = <String, List<BeatConfig>>{};
    for (final node in nodes) {
      final beatConfigs = node.beatConfigs.values.expand((element) => element);
      for (final beat in beatConfigs) {
        final eventName = beat.event;
        events[eventName] ??= [];
        events[eventName]!.add(beat);
      }
    }
    return events;
  }

  String _createSender(Map<String, List<BeatConfig>> events) {
    final rootEnumName = baseEnum.name;
    final buffer = StringBuffer();
    for (final event in events.keys) {
      final beatConfigs = events[event]!;
      final transitionName = '\$$event';

      /// sender method
      /// TODO: support delayed transition
      buffer.writeln('$transitionName<Data>([Data? data]) {');

      final commonTransition = beatConfigs.where((config) {
        return config.fromBase == rootEnumName &&
            config.fromBase == config.fromField;
      }).fold<String>('', (result, beatConfig) {
        return '''
  return _station.\$$event(data);
''';
      });
      final rootTransitions = beatConfigs.where((config) {
        return config.fromBase == rootEnumName &&
            config.fromBase != config.fromField;
      }).map((beatConfig) {
        final fromBase = beatConfig.fromBase;
        final fromField = beatConfig.fromField;
        return '''
if (_station.$currentStateFieldName.${toStateMatcher(fromBase, fromField)}) {
  return _station.${toTransitionFieldName(fromField)}.\$$event(data);
}
''';
      });

      final childTransitons = beatConfigs.where((config) {
        return config.fromBase != rootEnumName;
      }).fold<Set<String>>(<String>{}, (transitions, config) {
        final fromBase = config.fromBase;
        final route = beatTree.routeBetween(from: rootEnumName, to: fromBase);
        final childName = route.first.info.baseEnumName;
        return transitions..add(childName);
      }).map((substation) {
        final node = beatTree.getNode(substation);
        final parentBase = node.parentBase;
        final parentField = node.parentField;
        final substationName = toSubstationFieldName(substation);
        return '''
if (_station.$currentStateFieldName.${toStateMatcher(parentBase, parentField)}) {
  return _station.$substationName.send.\$$event(data);
}
''';
      });

      /// Parent transitions always have priority.
      /// The priority is as follows:
      /// Parent's common transitions > Parent's specific transitions > Child's transitions
      buffer.writeln(
        [
          if (commonTransition.isNotEmpty) commonTransition,
          if (commonTransition.isEmpty) ...rootTransitions,
          if (rootTransitions.isEmpty) ...childTransitons
        ].join(' else '),
      );

      buffer.writeln('}');
    }
    return buffer.toString();
  }
}
