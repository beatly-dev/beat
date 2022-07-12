import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_generator/src/utils/annotation.dart';
import 'package:beat_generator/src/utils/transitions.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'utils/string.dart';

class StationGenerator extends GeneratorForAnnotation<BeatStation> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement || !element.isEnum) {
      throw 'BeatStation can only be used on enums';
    }
    final stationName = '${element.name}Station';
    final states = element.fields
        .where((field) => field.isEnumConstant)
        .map((field) => field.name)
        .toList();
    final beats = mapBeatAnnotations(element.fields);
    final transitionClasses = generateBeatTransitions(element.name, beats);

    final listenStates = createHelperMethods('listen', states);
    final detachStates = createHelperMethods('detach', states);
    final whenStates = createHelperMethods('when', states);
    final mapStates = createHelperMethods(
      'map',
      states,
      callbackType: 'T Function<T>()',
    );

    final currentStateField = Field(
      (builder) {
        builder
          ..name = '_currentState'
          ..type = refer(element.name)
          ..late = true;
      },
    );
    final currentStateGetter = Method((builder) {
      builder
        ..returns = refer(element.name)
        ..type = MethodType.getter
        ..name = 'currentState'
        ..body = Code('return _currentState;');
    });
    var listenersField = Field((builder) {
      builder
        ..name = '_listeners'
        ..type = refer('Map<${element.name}, List<void Function()>>')
        ..assignment = Code('{}')
        ..modifier = FieldModifier.final$;
    });
    var notifyListenersMethod = Method((method) {
      method
        ..name = '_notifyListeners'
        ..returns = refer('void')
        ..body = Code('''
for(final listener in _listeners[_currentState] ?? []) {
  listener();
}
''');
    });
    final stationClass = Class((builder) {
      builder
        ..name = stationName
        ..fields.add(currentStateField)
        ..fields.add(listenersField)
        ..methods.add(notifyListenersMethod)
        ..constructors.add(createStationConstructor(element))
        ..methods.add(currentStateGetter)
        ..methods.addAll(listenStates)
        ..methods.addAll(detachStates)
        ..methods.addAll(whenStates)
        ..methods.addAll(mapStates);
    });
    final library = Library((builder) {
      builder
        ..body.add(stationClass)
        ..body.addAll(transitionClasses.values)
        ..directives.add(Directive((builder) {
          builder
            ..type = DirectiveType.import
            ..url = element.source.shortName;
        }));
    });
    return library.accept(DartEmitter()).toString();
  }

  Constructor createStationConstructor(ClassElement element) {
    return Constructor((builder) {
      builder
        ..requiredParameters.add(Parameter((builder) {
          builder
            ..name = 'initialState'
            ..type = refer(element.name);
        }))
        ..body = Code('''
            _currentState = initialState;
          ''');
    });
  }

  List<Method> createHelperMethods(
    String name,
    List<String> states, {
    String callbackType = 'void Function()',
  }) {
    final methods = <Method>[
      Method((builder) {
        final or = Parameter((builder) {
          builder
            ..name = 'or'
            ..named = true
            ..required = true
            ..type = refer(callbackType);
        });
        builder
          ..name = name
          ..optionalParameters.add(or)
          ..body = Code('');
      })
    ];
    final callbackParam = Parameter((builder) {
      builder
        ..name = 'callback'
        ..type = refer(callbackType);
    });
    for (final state in states) {
      final method = Method((builder) {
        builder
          ..name = '${name}On${toBeginningOfSentenceCase(state)}'
          ..requiredParameters.add(callbackParam)
          ..body = Code('');
      });
      methods.add(method);
    }
    return methods;
  }
}
