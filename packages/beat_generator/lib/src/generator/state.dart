import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import 'utils/string.dart';

const _baseClass = 'BeatState';

class InheritedBeatState {
  const InheritedBeatState({
    required this.element,
    required this.store,
  });

  final EnumElement element;
  final StationDataStore store;

  String get name => element.name;
  String get stateName => toStateName(name);
  BeatStationNode get node => store.stations[name]!;
  String get contextType => node.contextType;

  @override
  String toString() {
    return '''
class $stateName extends $_baseClass<$name, ${contextType.replaceAll('?', '')}> {
  const $stateName(super.state, super.context, super.station);
}
''';
  }
}
