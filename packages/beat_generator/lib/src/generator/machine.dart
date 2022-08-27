import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import 'utils/string.dart';

const _baseClass = 'BeatMachine';

class InheritedBeatMachine {
  const InheritedBeatMachine({
    required this.element,
    required this.store,
  });

  final EnumElement element;
  final StationDataStore store;

  String get name => element.name;
  String get stationName => toStationName(name);
  String get machineName => toMachineName(name);
  String get senderName => toSenderName(name);
  BeatStationNode get node => store.stations[name]!;

  List<BeatConfig> allBeats(BeatStationNode node) {
    final beats = <BeatConfig>[];
    beats.addAll(
      node.beats.values
          .expand((beats) => beats)
          .where((beat) => beat.event.isNotEmpty),
    );
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

  Set<String> get events => allBeats(node).map((beat) => beat.event).toSet();

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
  late final root = $stationName(machine: this);

  @override 
  late final send = $senderName(this);
}

class $senderName extends MachineSender {
  const $senderName(super.machine);

  $senderMethods
}
''';
  }
}
