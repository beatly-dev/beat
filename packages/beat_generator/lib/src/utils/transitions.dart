import 'package:beat_generator/src/utils/string.dart';
import 'package:code_builder/code_builder.dart';

import '../models/beat_config.dart';

Map<String, Class> generateBeatTransitions(
    String stateType, Map<String, List<BeatConfig>> configMap) {
  final beatCallback = Field((builder) {
    builder
      ..name = '_beat'
      ..modifier = FieldModifier.final$
      ..type = refer('void Function($stateType nextState)');
  });
  return configMap.map((from, configs) {
    final methods = configs.map(
      (config) => Method((builder) {
        final action = config.action;
        final to = config.to;
        builder
          ..name = '\$$action'
          ..returns = refer('void')
          ..body = Code('''
_beat($stateType.$to);
''');
      }),
    );
    return MapEntry(
      from,
      Class((builder) {
        builder
          ..name = '${toBeginningOfSentenceCase(from)}Beats'
          ..constructors.add(Constructor((builder) {
            builder
              ..requiredParameters.add(Parameter((builder) {
                builder.name = 'this._beat';
              }))
              ..constant = true;
          }))
          ..fields.add(beatCallback)
          ..methods.addAll(methods);
      }),
    );
  });
}
