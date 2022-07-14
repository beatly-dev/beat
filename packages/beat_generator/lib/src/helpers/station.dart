import 'package:analyzer/dart/element/element.dart';
import 'package:beat_generator/src/constants/field_names.dart';
import 'package:beat_generator/src/utils/context.dart';
import 'package:code_builder/code_builder.dart';

import '../utils/string.dart';

Constructor createStationConstructor(
  ClassElement element,
  List<Class> transitionClasses,
  String contextType,
) {
  return Constructor((builder) {
    builder
      ..requiredParameters.add(Parameter((builder) {
        builder.name = 'this.$initialStateFieldName';
      }))
      ..initializers.addAll([
        Code('''
  $privateCurrentStateFieldName = $initialStateFieldName
'''),
      ])
      ..body = Code(transitionClasses.fold('', (code, beatClass) {
        return '''
$code _${toDartFieldCase(beatClass.name)} = ${beatClass.name}(_setState ${isNotNullContextType(contextType) ? ', $setContextMethodName' : ''});
''';
      }));
    if (isNotNullContextType(contextType)) {
      final contextParamter = Parameter((builder) {
        builder
          ..name = 'this.$initialContextFieldName'
          ..named = true
          ..required = !(isNullableContextType(contextType));
      });
      builder
        ..optionalParameters.add(contextParamter)
        ..initializers.add(
          Code('''
  $privateCurrentContextFieldName = $initialContextFieldName
'''),
        );
    }
  });
}
