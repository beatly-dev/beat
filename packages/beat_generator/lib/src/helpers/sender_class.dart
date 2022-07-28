import '../models/beat_config.dart';
import '../utils/string.dart';

class SenderClassBuilder {
  final Map<String, List<BeatConfig>> beats;
  final List<BeatConfig> commonBeats;
  final String baseName;

  SenderClassBuilder({
    required this.beats,
    required this.commonBeats,
    required this.baseName,
  });

  String build() {
    final buffer = StringBuffer();
    final allEvents = _collectEvents();
    final eventsToBeats = _eventsToBeats();
    buffer.writeln('class ${toBeatSenderClassName(baseName)} {');
    buffer.writeln(
      '''
    final ${toBeatStationClassName(baseName)} _beatStation;
    const ${toBeatSenderClassName(baseName)}(${toBeatStationClassName(baseName)} beatStation) : _beatStation = beatStation;
  ''',
    );

    for (final event in allEvents) {
      buffer.writeln('\$$event<Data>([Data? data]) {');
      final beatConfigs = eventsToBeats[event]!;
      buffer.writeln(_eventsExecutor(event, beatConfigs));

      buffer.writeln('}');
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _eventsExecutor(String event, List<BeatConfig> beatConfigs) {
    return beatConfigs.map((config) {
      final from = config.from;
      final fieldName = toDartFieldCase(from);
      if (from == baseName) {
        return ' _beatStation.\$$event(data); ';
      }
      return '''
if (_beatStation.currentState.state == $baseName.$from) {
  _beatStation.$fieldName.\$$event(data);
}
''';
    }).join('else ');
  }

  Set<String> _collectEvents() {
    return <String>{
      ...commonBeats.map((e) => e.event),
      ...beats.values.expand((list) => list).map((e) => e.event),
    };
  }

  Map<String, List<BeatConfig>> _eventsToBeats() {
    final eventsToBeats = <String, List<BeatConfig>>{};

    for (final beat in commonBeats) {
      if (eventsToBeats[beat.event] == null) {
        eventsToBeats[beat.event] = [beat];
      } else {
        eventsToBeats[beat.event]!.add(beat);
      }
    }

    for (final beatList in beats.values) {
      for (final beat in beatList) {
        if (eventsToBeats[beat.event] == null) {
          eventsToBeats[beat.event] = [beat];
        } else {
          eventsToBeats[beat.event]!.add(beat);
        }
      }
    }
    return eventsToBeats;
  }
}
