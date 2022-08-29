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

  String get children => node.vars.map(
        (child) {
          final childClassName = toChildClassName(name, child);
          return '''
late final $childClassName ${toDartFieldCase(child)} = $childClassName(
  machine: machine,
  parent: this,
);
''';
        },
      ).join();

  String get childrenClasses => node.vars.map((child) {
        final enumName = node.stationName[child]!;
        final childStation = toStationName(enumName);
        final childClassName = toChildClassName(name, child);
        final initialState = node.initialStates[child];
        return '''
class $childClassName extends $childStation {
  $childClassName({
    required super.machine,
    super.parent,
  });

  @override
  String get id => '$child';

  ${initialState != null ? '''
@override
${enumName}State get initialState => ${enumName}State(
  $enumName.$initialState,
  ${toAnnotationName(enumName)}.initialContext,
  this,
);
''' : ''}
}
''';
      }).join();

  @override
  String toString() {
    return '''
class $stationName extends $_baseClass {
  $stationName({required super.machine, super.parent});

  @override
  String get id => '${node.id ?? '\$$name.\$hashCode'}';

  $children

  @override
  late final List<BeatStation> parallels = [
    ${node.vars.map((child) => toDartFieldCase(child)).join(',')}
  ];
}

$childrenClasses
''';
  }
}

String toChildClassName(String parallel, String child) {
  return '${toBeginningOfSentenceCase(parallel)}\$$child';
}
