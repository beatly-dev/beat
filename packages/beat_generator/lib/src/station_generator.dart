import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_generator/src/constants/field_names.dart';
import 'package:beat_generator/src/helpers/notifier.dart';
import 'package:beat_generator/src/helpers/state.dart';
import 'package:beat_generator/src/utils/annotation.dart';
import 'package:beat_generator/src/utils/context.dart';
import 'package:beat_generator/src/utils/transitions.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'helpers/attach.dart';
import 'helpers/context.dart';
import 'helpers/detach.dart';
import 'helpers/mapper.dart';
import 'helpers/station.dart';
import 'helpers/when.dart';
import 'utils/string.dart';

class StationGenerator extends GeneratorForAnnotation<BeatStation> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement || !element.isEnum) {
      throw 'BeatStation can only be used on enums';
    }
    final contextType = annotation
        .read('contextType')
        .typeValue
        .getDisplayString(withNullability: false);
    final stationName = '${element.name}Station';
    final states = element.fields
        .where((field) => field.isEnumConstant)
        .map((field) => field.name)
        .toList();
    final beats = mapBeatAnnotations(element.name, element.fields);
    final commonBeats = mapCommonBeatAnnotations(element.name, [element]);
    final Map<String, Class> transitionClasses = generateBeatTransitionClasses(
      element.name,
      beats,
      contextType,
      commonBeats,
    );

    final attachStates = createAttachMethods(states, transitionClasses);
    final detachStates = createDetachMethods(states, transitionClasses);
    final whenStates = createWhenMethods(states, transitionClasses);
    final mapStates = createMapMethods(states, transitionClasses);

    final transitionBeatFields = createTransitionBeatFields(transitionClasses);

    final resetMethod = createResetMethod(contextType);

    final stationClass = Class((builder) {
      builder
        ..name = stationName
        ..constructors.add(
          createStationConstructor(
            element,
            transitionClasses.values.toList(),
            contextType,
          ),
        )
        ..fields.addAll(transitionBeatFields)
        ..methods.add(resetMethod)
        ..methods.addAll(attachStates)
        ..methods.addAll(detachStates)
        ..methods.addAll(mapStates)
        ..methods.addAll(whenStates);
      if (isNotNullContextType(contextType)) {
        BeatContextBuilder(contextType).build(builder);
      }
      BeatStateBuilder(element).build(builder);
      BeatNotifierBuilder().build(builder);
    });
    final library = Library((builder) {
      builder
        ..body.add(stationClass)
        ..body.addAll(transitionClasses.values);
    });
    return library.accept(DartEmitter()).toString();
  }

  Method createResetMethod(String contextType) {
    return Method((builder) {
      builder
        ..name = 'reset'
        ..body = Code('''
$privateCurrentStateFieldName = $initialStateFieldName;
${isNotNullContextType(contextType) ? "$privateCurrentContextFieldName = $initialContextFieldName;" : ""}
$notifyListenersMethodName();
''');
    });
  }

  Iterable<Field> createTransitionBeatFields(
      Map<String, Class> transitionClasses) {
    return transitionClasses.values.map((transitionClass) {
      return Field((builder) {
        builder
          ..name = '_${toDartFieldCase(transitionClass.name)}'
          ..type = refer(transitionClass.name)
          ..late = true
          ..modifier = FieldModifier.final$;
      });
    });
  }
}
