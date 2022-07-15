import 'package:code_builder/code_builder.dart';

import '../constants/field_names.dart';
import '../utils/string.dart';

List<Method> createMapMethods(
  List<String> states,
  Map<String, Class> transitions,
) {
  final methods = <Method>[
    Method((builder) {
      final or = Parameter((builder) {
        builder
          ..name = 'or'
          ..named = true
          ..required = true
          ..type = refer('T Function()');
      });
      final conditions = states.asMap().keys.map((index) {
        var needElse = false;
        if (index != 0) {
          needElse = true;
        }
        String beatModifier = '';
        final beatClass = transitions[states[index]];
        if (beatClass != null) {
          beatModifier = '_${toDartFieldCase(beatClass.name)}';
        }
        return '''${needElse ? "else" : ""} if (currentState.name == '${states[index]}' 
        && ${states[index]} != null) {
          return ${states[index]}($beatModifier);
          }''';
      }).toList()
        ..add('return or();');

      // generate named callback arguments for each states
      final stateMethods = states.map((state) => Parameter((builder) {
            builder
              ..name = state
              ..named = true
              ..type = refer('T Function(${transitions[state]?.name ?? ''})?');
          }));
      builder
        ..name = 'T map<T>'
        ..optionalParameters.add(or)
        ..optionalParameters.addAll(stateMethods)
        ..body = Code(conditions.join());
    })
  ];
  for (final state in states) {
    final beatClass = transitions[state];
    String beatModifier = '';
    if (beatClass != null) {
      beatModifier = '_${toDartFieldCase(beatClass.name)}';
    }
    final callbackParam = Parameter((builder) {
      builder
        ..name = 'callback'
        ..type = refer('T Function(${beatClass?.name ?? ""})');
    });
    final method = Method((builder) {
      builder
        ..name = 'T? map${toBeginningOfSentenceCase(state)}<T>'
        ..requiredParameters.add(callbackParam)
        ..body = Code('''
if ($currentStateFieldName.name == '$state') {
  return callback($beatModifier);
}
return null;
          ''');
    });
    methods.add(method);
  }
  return methods;
}
