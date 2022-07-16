import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

import '../models/beat_config.dart';
import '../utils/context.dart';
import '../utils/string.dart';

const _setContextMethodName = '_setContext';
Map<String, Class> generateBeatTransitionClasses(
  ClassElement rootEnum,
  String stateType,
  Map<String, List<BeatConfig>> beatConfigs,
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
      ..type = refer(
        'Future Function(FutureOr<$contextType> Function(${rootEnum.name} currentState, $contextType context, String event), String event)',
      );
  });
  return beatConfigs.map((from, configs) {
    final methods = configs.map(
      (config) => Method((builder) {
        final action = config.event;
        final to = config.to;
        final assign = config.assign.isEmpty || isNullContextType(contextType)
            ? ''
            : 'await $_setContextMethodName(${config.assign}, "$action");';
        builder
          ..name = '\$$action'
          ..modifier = MethodModifier.async
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
