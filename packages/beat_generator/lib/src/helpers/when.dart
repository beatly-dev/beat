import 'package:analyzer/dart/element/element.dart';
import 'package:beat_generator/src/constants/field_names.dart';
import 'package:code_builder/code_builder.dart';

import '../utils/string.dart';

List<Method> createWhenMethods(
  ClassElement rootEnum,
  List<String> states,
  Map<String, Class> transitions,
) {
  final name = 'when';
  final methods = <Method>[
    // default `when` method
    Method((builder) {
      // generate default handler `or`
      final or = Parameter((builder) {
        builder
          ..name = 'or'
          ..named = true
          ..required = true
          ..type = refer('Function()');
      });

      // generate if and else if conditions
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
        return '''${needElse ? "else" : ""} if ($currentStateFieldName == ${rootEnum.name}.${states[index]}
        && ${states[index]} != null) {
          return ${states[index]}($beatModifier);
          }''';
      }).toList()
        ..add('or();');

      // generate named callback arguments for each states
      final stateMethods = states.map((state) => Parameter((builder) {
            builder
              ..name = state
              ..named = true
              ..type = refer('Function(${transitions[state]?.name ?? ''})?');
          }));
      builder
        ..name = name
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
        ..type = refer('Function(${beatClass?.name ?? ""})');
    });
    final method = Method((builder) {
      builder
        ..name = '$name${toBeginningOfSentenceCase(state)}'
        ..requiredParameters.add(callbackParam)
        ..body = Code('''
if ($currentStateFieldName == ${rootEnum.name}.$state) {
  callback($beatModifier);
}
          ''');
    });
    methods.add(method);
  }
  return methods;
}
