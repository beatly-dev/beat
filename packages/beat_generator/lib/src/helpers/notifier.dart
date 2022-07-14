import 'package:beat_generator/src/constants/field_names.dart';
import 'package:code_builder/code_builder.dart';

class BeatNotifierBuilder {
  void build(ClassBuilder builder) {
    builder
      ..fields.add(_createListenersField())
      ..methods.add(_createNotifyListenerMethod());
  }

  Method _createNotifyListenerMethod() {
    return Method((method) {
      method
        ..name = notifyListenersMethodName
        ..returns = refer('void')
        ..body = Code('''
for(final listener in $listenersFieldName[$privateCurrentStateFieldName.name]?.toList() ?? []) {
listener();
}
''');
    });
  }

  Field _createListenersField() {
    return Field((builder) {
      builder
        ..name = listenersFieldName
        ..type = refer('Map<String, Set<Function()>>')
        ..assignment = Code('{}')
        ..modifier = FieldModifier.final$;
    });
  }
}
