import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import 'utils/string.dart';

const _baseClass = 'BeatMachine';

class InheritedBeatMachine {
  const InheritedBeatMachine({
    required this.element,
    required this.store,
  });

  final ClassElement element;
  final StationDataStore store;

  String get name => element.name;
  String get stationName => toStationName(name);
  String get machineName => toMachineName(name);
  String get senderName => toSenderName(name);
  BeatStationNode get node => store.stations[name]!;

  List<BeatConfig> allBeats(String stationName) {
    final normal = store.stations[stationName];
    final parallel = store.parallels[stationName];
    final beats = <BeatConfig>[];
    if (normal != null) {
      beats.addAll(normal.beats.values.expand((beats) => beats));
      for (final sub in normal.substations.values) {
        beats.addAll(allBeats(sub));
      }
    }
    if (parallel != null) {
      for (final sub in parallel.vars) {
        final enumName = parallel.stationName[sub]!;
        beats.addAll(allBeats(enumName));
      }
    }
    return beats;
  }

  Set<String> get events => allBeats(name)
      .map((beat) => beat.event)
      .where((event) => event.isNotEmpty)
      .toSet();

  String get senderMethods {
    return events.map((event) {
      return '''
int \$$event<Data>({
  Data? data,
  Duration after = const Duration(),
  Type? target,
}) => this('$event', data: data, after: after, target: target);
''';
    }).join();
  }

  @override
  String toString() {
    return '''
class $machineName extends $_baseClass {
  @override
  $stationName get root => _root;

  late final $stationName _root = $stationName(machine: this);

  @override 
  late final $senderName send = $senderName(this);
}

class $senderName extends MachineSender {
  const $senderName(super.machine);

  $senderMethods
}
''';
  }
}
