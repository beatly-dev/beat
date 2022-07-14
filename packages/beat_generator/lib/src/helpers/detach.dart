import 'package:beat_generator/src/constants/field_names.dart';
import 'package:code_builder/code_builder.dart';

import '../utils/string.dart';

List<Method> createDetachMethods(
  List<String> states,
  Map<String, Class> transitions,
) {
  final name = 'detach';
  final methods = <Method>[
    Method((builder) {
      final or = Parameter((builder) {
        builder
          ..name = 'callback'
          ..type = refer('Function()');
      });
      builder
        ..name = name
        ..requiredParameters.add(or)
        ..body = Code(
          states
              .map(
                  (state) => "$listenersFieldName['$state']?.remove(callback);")
              .join(),
        );
    })
  ];
  for (final state in states) {
    final callbackParam = Parameter((builder) {
      builder
        ..name = 'callback'
        ..type = refer('Function()');
    });
    final method = Method((builder) {
      builder
        ..name = '${name}On${toBeginningOfSentenceCase(state)}'
        ..requiredParameters.add(callbackParam)
        ..body = Code('''
$listenersFieldName['$state']?.remove(callback);
          ''');
    });
    methods.add(method);
  }
  return methods;
}
