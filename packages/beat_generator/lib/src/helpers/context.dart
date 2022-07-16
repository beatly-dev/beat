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
        ..returns = refer('FutureOr<$contextType>')
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
final nextContext = modifier(currentState, _currentContext, event);
if (nextContext is Future<$contextType>) {
  return nextContext.then((value) {
    _currentContext = value;
    return value;
  });
} else {
  _currentContext = nextContext;
  return nextContext;
}
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
