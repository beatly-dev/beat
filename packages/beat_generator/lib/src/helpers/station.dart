import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

import '../utils/string.dart';

Constructor createStationConstructor(
  ClassElement element,
  List<Class> transitionClasses,
  String contextType,
) {
  final contextParamter = Parameter((builder) {
    builder
      ..name = 'this.initialContext'
      ..named = true
      ..required = !(contextType.contains('?') ||
          contextType == 'void' ||
          contextType == 'Null' ||
          contextType == 'dynamic');
  });
  return Constructor((builder) {
    builder
      ..requiredParameters.add(Parameter((builder) {
        builder.name = 'this.initialState';
      }))
      ..optionalParameters.add(contextParamter)
      ..initializers.addAll([
        Code('''
  _currentState = initialState
'''),
        Code('''
  _currentContext = initialContext
'''),
      ])
      ..body = Code(transitionClasses.fold('', (code, beatClass) {
        return '''
$code _${toDartFieldCase(beatClass.name)} = ${beatClass.name}(_setState, _setContext);
''';
      }));
  });
}
