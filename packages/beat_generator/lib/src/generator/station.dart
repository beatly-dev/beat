import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../utils/string.dart';
import 'utils/string.dart';

const _baseClass = 'BeatStation';

class InheritedBeatStation {
  const InheritedBeatStation({
    required this.element,
    required this.store,
  });

  final EnumElement element;
  final StationDataStore store;

  String get name => element.name;
  String get stateName => toStateName(name);
  String get stationName => toStationName(name);
  String get annotationName => toAnnotationName(name);
  BeatStationNode get node => store.stations[name]!;
  List<String> get states => node.states;
  String get contextType => node.contextType;
  String get source => node.source ?? 'Station()';

  String get children {
    final children = states.map((state) {
      final substation = node.substations[state];
      if (substation == null) return '';
      final stationName = toStationName(substation);
      final fieldName =
          '${toDartFieldCase(stationName)}On${toBeginningOfSentenceCase(state)}';
      return '''
late final $stationName $fieldName = $stationName(machine: machine, parent: this);
''';
    }).join();

    final childrenMap = states.map((state) {
      final substation = node.substations[state];
      if (substation == null) {
        return '';
      }
      final stationName = toStationName(substation);
      final fieldName =
          '${toDartFieldCase(stationName)}On${toBeginningOfSentenceCase(state)}';
      return '''
$name.$state: $fieldName,
''';
    }).join();

    return '''
  $children
  Map<$name, BeatStation> get _children => {
    $childrenMap
  };
''';
  }

  String get isFinalState => node.finalState.map((state) {
        return '''
currentState.state == $name.$state
''';
      }).join(' || ');

  String get beatMap => node.beats.keys
          .where(
        (state) => state != name && state != 'values',
      )
          .map((state) {
        final beats = node.beats[state] ?? [];
        final beatsList = beats.map((beat) {
          return '''
${beat.source}
''';
        }).join(', ');
        return '''
$name.$state: [
  $beatsList
],
''';
      }).join();

  String get stationBeatMap =>
      node.beats.keys.where((state) => state == name).map((state) {
        final beats = node.beats[state] ?? [];
        return beats.map((beat) {
          return '''
${beat.source}
''';
        }).join(', ');
      }).join();

  String get stateEntry => node.stateEntry.keys
      .where((state) => state != name && state != 'values')
      .map(
        (state) => '''
$name.$state: ${node.stateEntry[state] ?? 'OnEntry()'},
''',
      )
      .join();

  String get stateExit => node.stateExit.keys
      .where((state) => state != name && state != 'values')
      .map(
        (state) => '''
$name.$state: ${node.stateExit[state] ?? 'OnExit()'},
''',
      )
      .join();

  String get stateServices => node.stateExit.keys
          .where((state) => state != name && state != 'values')
          .map(
        (state) {
          final services = node.services[state] ?? [];
          final items = services.map((service) {
            return '''
${service.source}
''';
          }).join(', ');

          return '''
        $name.$state: ${items.isEmpty ? '[]' : '[$items]'},
        ''';
        },
      ).join();

  @override
  String toString() {
    return '''
const $annotationName = $source;
class $stationName extends $_baseClass<$stateName> {
  $stationName({required super.machine, super.parent});

  $children

  @override
  BeatStation? get child => _children[currentState.state];
  
  @override
  late final $stateName initialState = $stateName(
    ($annotationName.initialState ?? $name.${states.first}) as $name, 
    $annotationName.initialContext,
    this,
  );

  @override
  late final String id = $annotationName.id ?? '\$$name.\$hashCode';

  @override
  late final List<dynamic> entry = ${node.stationEntry}.actions;

  @override
  late final List<dynamic> exit = ${node.stationExit}.actions;

  @override
  late final bool done = ${isFinalState.isEmpty ? 'false' : isFinalState};

  @override
  late final List<Beat> stationBeats = [
    $stationBeatMap
  ];

  @override
  late final Map<$name, List<Beat>> stateToBeat = {
    $beatMap
  };

  @override
  late final Map<$name, OnEntry> stateEntry = {
    $stateEntry
  };

  @override
  late final Map<$name, OnExit> stateExit = {
    $stateExit
  };

  @override
  late final Map<$name, List<Services>> stateServices = {
    $stateServices
  };
}
''';
  }
}
