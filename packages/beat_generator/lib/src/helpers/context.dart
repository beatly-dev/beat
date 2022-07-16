import 'package:analyzer/dart/element/element.dart';
import 'package:beat_generator/src/constants/field_names.dart';
import 'package:code_builder/code_builder.dart';

class BeatContextBuilder {
  const BeatContextBuilder(this.rootEnum, this.contextType);
  final String contextType;
  final ClassElement rootEnum;

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
        ..name = setContextMethodName
        ..modifier = MethodModifier.async
        ..returns = refer('Future')
        ..requiredParameters.add(Parameter((builder) {
          builder
            ..name = 'modifier'
            ..type = refer(
                'FutureOr<$contextType> Function(${rootEnum.name} currentState, $contextType context, String event)');
        }))
        ..requiredParameters.add(Parameter((builder) {
          builder
            ..name = 'event'
            ..type = refer('String');
        }))
        ..body = Code('''
$privateCurrentContextFieldName = await modifier($currentStateFieldName, $privateCurrentContextFieldName, event);
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
