import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import 'utils/string.dart';

class BeatEvents {
  const BeatEvents({
    required this.element,
    required this.store,
  });

  final EnumElement element;
  final StationDataStore store;

  String get name => element.name;
  String get className => toEventClassName(name);
  BeatStationNode get node => store.stations[name]!;

  List<BeatConfig> explicitBeats(BeatStationNode node) {
    return node.beats.values
        .expand((beats) => beats)
        .where((beat) => beat.event.isNotEmpty)
        .toList();
  }

  List<BeatConfig> allBeats(BeatStationNode node) {
    final beats = <BeatConfig>[];
    beats.addAll(explicitBeats(node));
    for (final child in node.substations.values) {
      final station = store.stations[child];
      if (station == null) {
        /// skip the parallel station
        /// it does not have any transitions
        continue;
      }
      beats.addAll(allBeats(station));
    }
    return beats;
  }

  Set<String> get allEvents => allBeats(node).map((beat) => beat.event).toSet();

  String get ownEvents {
    return explicitBeats(node)
        .map((beat) {
          return '''
static const \$${beat.event} = '${beat.event}';
''';
        })
        .toSet()
        .join();
  }

  String get nestedEvents {
    return allEvents.map((event) {
      return '''
final \$$event = '$event';
''';
    }).join();
  }

  @override
  String toString() {
    return '''
class $className{
  $ownEvents
  static const nested = ${toNestedEventClassName(name)}();
}

class ${toNestedEventClassName(name)} {
  const ${toNestedEventClassName(name)}();
  $nestedEvents
}
''';
  }
}
