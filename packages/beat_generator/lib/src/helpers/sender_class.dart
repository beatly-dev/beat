import 'package:beat_config/beat_config.dart';

import '../utils/string.dart';

class SenderClassBuilder {
  final Map<String, List<BeatConfig>> beats;
  final List<BeatConfig> commonBeats;
  final List<SubstationConfig> compounds;
  final String baseName;

  late final String beatStationFieldName;

  SenderClassBuilder({
    required this.beats,
    required this.commonBeats,
    required this.baseName,
    required this.compounds,
  }) {
    beatStationFieldName = toBeatSenderBeatStationFieldName(baseName);
  }

  String build() {
    final buffer = StringBuffer();
    final allEvents = _collectEvents();
    final eventsToBeats = _eventsToBeats();
    final compoundSender = compounds.map((compound) {
      return toBeatSenderClassName(compound.childBase);
    }).join(', ');
    final extendsCompound =
        compoundSender.isEmpty ? '' : 'extends $compoundSender';

    buffer
        .writeln('class ${toBeatSenderClassName(baseName)} $extendsCompound {');
    buffer.writeln(
      '''
    late final ${toBeatStationClassName(baseName)} $beatStationFieldName;
    ''',
    );

    final initializeArguments = [
      baseName,
      ...compounds.map((compound) {
        return compound.childBase;
      }),
    ]
        .map(
          (name) =>
              '${toBeatStationClassName(name)} ${toBeatSenderInitializerArgumentName(name)}',
        )
        .join(',');
    final initializerBody = [
      baseName,
      ...compounds.map((compound) {
        return compound.childBase;
      }),
    ].map((name) {
      return '${toBeatSenderBeatStationFieldName(name)} = ${toBeatSenderInitializerArgumentName(name)};';
    }).join(' ');

    buffer.writeln(
      '''
    ${toBeatSenderInitializerMethodName(baseName)}($initializeArguments) {
      $initializerBody
    }
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
      final from = config.fromField;
      final fieldName = toDartFieldCase(from);
      if (from == baseName) {
        return ' $beatStationFieldName.\$$event(data); ';
      }
      return '''
if ($beatStationFieldName.currentState.state == $baseName.$from) {
  $beatStationFieldName.$fieldName.\$$event(data);
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
