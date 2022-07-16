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
$code _${toDartFieldCase(beatClass.name)} = ${beatClass.name}($setStateMethodName ${isNotNullContextType(contextType) ? ', $setContextMethodName' : ''});
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

void buildNextEventsField(
  ClassBuilder builder,
  ClassElement rootEnum,
  Map<String, Class> transitionClasses,
) {
  final body = '${transitionClasses.keys.map((state) {
    final transitionClassName = transitionClasses[state]!.name;
    return '''
if ($currentStateFieldName == ${rootEnum.name}.$state) {
  return _${toDartFieldCase(transitionClassName)}.$nextEventsFieldName;
}
''';
  }).join(' else ')}return [];';
  builder.methods.add(Method((builder) {
    builder
      ..name = nextEventsFieldName
      ..type = MethodType.getter
      ..returns = refer('List<String>')
      ..body = Code(body);
  }));
}

void buildDoneField(ClassBuilder builder) {
  final body = '''
return $nextEventsFieldName.isEmpty;
''';
  builder.methods.add(Method((builder) {
    builder
      ..name = doneFieldName
      ..type = MethodType.getter
      ..returns = refer('bool')
      ..body = Code(body);
  }));
}
