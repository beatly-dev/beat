import 'package:analyzer/dart/element/element.dart';
import 'package:beat_generator/src/constants/field_names.dart';
import 'package:beat_generator/src/models/beat_config.dart';
import 'package:code_builder/code_builder.dart';

class BeatStateBuilder {
  BeatStateBuilder(this.rootEnum, {required this.commonBeats});
  final ClassElement rootEnum;
  final List<BeatConfig> commonBeats;

  void build(ClassBuilder builder) {
    builder
      ..fields.add(_createCurrentStateField())
      ..fields.add(_createInitialStateField())
      ..methods.add(_createCurrentStateGetter())
      ..methods.add(_createSetStateMethod())
      ..methods.addAll(_createCommonBeatsMethods());
  }

  List<Method> _createCommonBeatsMethods() {
    return commonBeats.map((config) {
      return Method((builder) {
        builder
          ..name = '\$${config.event}'
          ..returns = refer('')
          ..body = Code('''
$setStateMethodName(${rootEnum.name}.${config.to});
''');
      });
    }).toList();
  }

  Method _createSetStateMethod() {
    return Method((builder) {
      builder
        ..name = setStateMethodName
        ..returns = refer('void')
        ..requiredParameters.add(Parameter((builder) {
          builder
            ..name = 'nextState'
            ..type = refer(rootEnum.name);
        }))
        ..body = Code('''
$privateCurrentStateFieldName = nextState;
$notifyListenersMethodName();
''');
    });
  }

  Method _createCurrentStateGetter() {
    return Method((builder) {
      builder
        ..returns = refer(rootEnum.name)
        ..type = MethodType.getter
        ..name = currentStateFieldName
        ..body = Code('return $privateCurrentStateFieldName;');
    });
  }

  Field _createCurrentStateField() {
    return Field(
      (builder) {
        builder
          ..name = privateCurrentStateFieldName
          ..type = refer(rootEnum.name);
      },
    );
  }

  Field _createInitialStateField() {
    return Field(
      (builder) {
        builder
          ..name = 'initialState'
          ..type = refer(rootEnum.name)
          ..modifier = FieldModifier.final$;
      },
    );
  }
}
