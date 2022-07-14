import 'package:beat_generator/src/constants/field_names.dart';
import 'package:code_builder/code_builder.dart';

class BeatContextBuilder {
  final String contextType;

  BeatContextBuilder(this.contextType);
  void build(ClassBuilder builder) {
    builder
      ..fields.add(_createCurrentContextField())
      ..fields.add(_createInitialContextField())
      ..methods.add(_createCurrentContextGetter())
      ..methods.add(_createSetContextMethod());
  }

  Method _createSetContextMethod() {
    return Method((builder) {
      builder
        ..name = '_setContext'
        ..requiredParameters.add(Parameter((builder) {
          builder
            ..name = 'modifier'
            ..type = refer('$contextType Function($contextType)');
        }))
        ..body = Code('''
$privateCurrentContextFieldName = modifier($privateCurrentContextFieldName);
''');
    });
  }

  Method _createCurrentContextGetter() {
    return Method((builder) {
      builder
        ..name = currentContextFieldName
        ..returns = refer(contextType)
        ..type = MethodType.getter
        ..body = Code('return $privateCurrentContextFieldName;');
    });
  }

  Field _createCurrentContextField() {
    return Field((builder) {
      builder
        ..name = privateCurrentContextFieldName
        ..type = refer(contextType);
    });
  }

  Field _createInitialContextField() {
    return Field((builder) {
      builder
        ..name = initialContextFieldName
        ..modifier = FieldModifier.final$
        ..type = refer(contextType);
    });
  }
}
