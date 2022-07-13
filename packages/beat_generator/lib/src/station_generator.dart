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
    final beats = mapBeatAnnotations(element.name, element.fields);
    final transitionClasses = generateBeatTransitions(element.name, beats);

    final attachStates =
        createAttachMethods('attach', states, transitionClasses);
    final detachStates =
        createDetachMethods('detach', states, transitionClasses);
    final whenStates = createWhenMethods('when', states, transitionClasses);
    final mapStates = createMapMethods('map', states, transitionClasses);

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
        ..type = refer('Map<String, Set<Function()>>')
        ..assignment = Code('{}')
        ..modifier = FieldModifier.final$;
    });
    var notifyListenersMethod = Method((method) {
      method
        ..name = '_notifyListeners'
        ..returns = refer('void')
        ..body = Code('''
for(final listener in _listeners[_currentState.name]?.toList() ?? []) {
  listener();
}
''');
    });
    final setStateMethod = Method((builder) {
      builder
        ..name = '_setState'
        ..returns = refer('void')
        ..requiredParameters.add(Parameter((builder) {
          builder
            ..name = 'nextState'
            ..type = refer(element.name);
        }))
        ..body = Code('''
_currentState = nextState;
_notifyListeners();
''');
    });

    final stateChangersField = transitionClasses.values.map((transitionClass) {
      return Field((builder) {
        builder
          ..name = '_${toDartFieldCase(transitionClass.name)}'
          ..type = refer(transitionClass.name)
          ..late = true
          ..modifier = FieldModifier.final$;
      });
    });

    final stationClass = Class((builder) {
      builder
        ..name = stationName
        ..constructors.add(
          createStationConstructor(element, transitionClasses.values.toList()),
        )
        ..fields.add(currentStateField)
        ..methods.add(currentStateGetter)
        ..methods.add(setStateMethod)
        ..fields.addAll(stateChangersField)
        ..fields.add(listenersField)
        ..methods.add(notifyListenersMethod)
        ..methods.addAll(attachStates)
        ..methods.addAll(detachStates)
        ..methods.addAll(mapStates)
        ..methods.addAll(whenStates);
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

  Constructor createStationConstructor(
    ClassElement element,
    List<Class> transitionClasses,
  ) {
    return Constructor((builder) {
      builder
        ..requiredParameters.add(Parameter((builder) {
          builder
            ..name = 'initialState'
            ..type = refer(element.name);
        }))
        ..initializers.add(Code('''
  _currentState = initialState
'''))
        ..body = Code(transitionClasses.fold('', (code, elm) {
          return '''
$code _${toDartFieldCase(elm.name)} = ${elm.name}(_setState);
''';
        }));
    });
  }
}

List<Method> createWhenMethods(
  String name,
  List<String> states,
  Map<String, Class> transitions,
) {
  final methods = <Method>[
    // default `when` method
    Method((builder) {
      // generate default handler `or`
      final or = Parameter((builder) {
        builder
          ..name = 'or'
          ..named = true
          ..required = true
          ..type = refer('Function()');
      });

      // generate if and else if conditions
      final conditions = states.asMap().keys.map((index) {
        var needElse = false;
        if (index != 0) {
          needElse = true;
        }
        String beatModifier = '';
        final beatClass = transitions[states[index]];
        if (beatClass != null) {
          beatModifier = '_${toDartFieldCase(beatClass.name)}';
        }
        return '''${needElse ? "else" : ""} if (currentState.name == '${states[index]}'
        && ${states[index]} != null) {
          return ${states[index]}($beatModifier);
          }''';
      }).toList()
        ..add('or();');

      // generate named callback arguments for each states
      final stateMethods = states.map((state) => Parameter((builder) {
            builder
              ..name = state
              ..named = true
              ..type = refer('Function(${transitions[state]?.name ?? ''})?');
          }));
      builder
        ..name = name
        ..optionalParameters.add(or)
        ..optionalParameters.addAll(stateMethods)
        ..body = Code(conditions.join());
    })
  ];
  for (final state in states) {
    final beatClass = transitions[state];
    String beatModifier = '';
    if (beatClass != null) {
      beatModifier = '_${toDartFieldCase(beatClass.name)}';
    }
    final callbackParam = Parameter((builder) {
      builder
        ..name = 'callback'
        ..type = refer('Function(${beatClass?.name ?? ""})');
    });
    final method = Method((builder) {
      builder
        ..name = '$name${toBeginningOfSentenceCase(state)}'
        ..requiredParameters.add(callbackParam)
        ..body = Code('''
callback($beatModifier);
          ''');
    });
    methods.add(method);
  }
  return methods;
}

List<Method> createMapMethods(
  String name,
  List<String> states,
  Map<String, Class> transitions,
) {
  final methods = <Method>[
    Method((builder) {
      final or = Parameter((builder) {
        builder
          ..name = 'or'
          ..named = true
          ..required = true
          ..type = refer('T Function()');
      });
      final conditions = states.asMap().keys.map((index) {
        var needElse = false;
        if (index != 0) {
          needElse = true;
        }
        String beatModifier = '';
        final beatClass = transitions[states[index]];
        if (beatClass != null) {
          beatModifier = '_${toDartFieldCase(beatClass.name)}';
        }
        return '''${needElse ? "else" : ""} if (currentState.name == '${states[index]}' 
        && ${states[index]} != null) {
          return ${states[index]}($beatModifier);
          }''';
      }).toList()
        ..add('return or();');

      // generate named callback arguments for each states
      final stateMethods = states.map((state) => Parameter((builder) {
            builder
              ..name = state
              ..named = true
              ..type = refer('T Function(${transitions[state]?.name ?? ''})?');
          }));
      builder
        ..name = 'T $name<T>'
        ..optionalParameters.add(or)
        ..optionalParameters.addAll(stateMethods)
        ..body = Code(conditions.join());
    })
  ];
  for (final state in states) {
    final beatClass = transitions[state];
    String beatModifier = '';
    if (beatClass != null) {
      beatModifier = '_${toDartFieldCase(beatClass.name)}';
    }
    final callbackParam = Parameter((builder) {
      builder
        ..name = 'callback'
        ..type = refer('T Function(${beatClass?.name ?? ""})');
    });
    final method = Method((builder) {
      builder
        ..name = 'T $name${toBeginningOfSentenceCase(state)}<T>'
        ..requiredParameters.add(callbackParam)
        ..body = Code('''
return callback($beatModifier);
          ''');
    });
    methods.add(method);
  }
  return methods;
}

List<Method> createAttachMethods(
  String name,
  List<String> states,
  Map<String, Class> transitions,
) {
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
              .map((state) =>
                  "_listeners['$state'] ??= {}; _listeners['$state']!.add(callback);")
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
_listeners['$state'] ??= {};
_listeners['$state']!.add(callback);
          ''');
    });
    methods.add(method);
  }
  return methods;
}

List<Method> createDetachMethods(
  String name,
  List<String> states,
  Map<String, Class> transitions,
) {
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
              .map((state) => "_listeners['$state']?.remove(callback);")
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
_listeners['$state'] ??= {};
_listeners['$state']!.remove(callback);
          ''');
    });
    methods.add(method);
  }
  return methods;
}
