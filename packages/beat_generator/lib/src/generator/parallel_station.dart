import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../utils/string.dart';
import 'utils/string.dart';

const _baseClass = 'ParallelBeatStation';

class InheritedParallelStation {
  const InheritedParallelStation({
    required this.element,
    required this.store,
  });

  final ClassElement element;
  final StationDataStore store;

  String get name => element.name;
  String get stationName => toParallelStationName(name);
  ParallelStationNode get node => store.parallels[name]!;

  String get children => node.stations.map(
        (child) {
          final childStation = toStationName(child);
          return '''
late final $childStation ${toDartFieldCase(childStation)} = $childStation(
  machine: machine,
  parent: this,
);
''';
        },
      ).join();

  @override
  String toString() {
    return '''
class $stationName extends $_baseClass {
  $stationName({required super.machine, super.parent});

  $children

  @override
  late final List<BeatStation> parallels = [
    ${node.stations.map((child) => toDartFieldCase(toStationName(child))).join(',')}
  ];
}
''';
  }
}
