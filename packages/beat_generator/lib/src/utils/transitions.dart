import 'package:beat_generator/src/utils/context.dart';
import 'package:beat_generator/src/utils/string.dart';
import 'package:code_builder/code_builder.dart';

import '../models/beat_config.dart';

const _setContextMethodName = '_setContext';
Map<String, Class> generateBeatTransitionClasses(
  String stateType,
  Map<String, List<BeatConfig>> configMap,
  String contextType,
) {
  final beatCallback = Field((builder) {
    builder
      ..name = '_beat'
      ..modifier = FieldModifier.final$
      ..type = refer('void Function($stateType nextState)');
  });
  final setContext = Field((builder) {
    builder
      ..name = _setContextMethodName
      ..modifier = FieldModifier.final$
      ..type = refer('Function($contextType Function($contextType))');
  });
  return configMap.map((from, configs) {
    final methods = configs.map(
      (config) => Method((builder) {
        final action = config.event;
        final to = config.to;
        final assign = config.assign.isEmpty
            ? ''
            : '$_setContextMethodName(${config.assign});';
        builder
          ..name = '\$$action'
          ..returns = refer('')
          ..body = Code('''
$assign
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
            if (isNotNullContextType(contextType)) {
              builder.requiredParameters.add(Parameter((builder) {
                builder.name = 'this.$_setContextMethodName';
              }));
            }
          }))
          ..fields.add(beatCallback)
          ..methods.addAll(methods);
        if (isNotNullContextType(contextType)) {
          builder.fields.add(setContext);
        }
      }),
    );
  });
}
