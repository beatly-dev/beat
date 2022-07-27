import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'helpers/beat_annotation_variables.dart';
import 'helpers/beat_state_class.dart';
import 'helpers/beat_transition_class.dart';
import 'helpers/invoke_services.dart';
import 'helpers/station_class.dart';
import 'utils/beat_annotation.dart';
import 'utils/invoke_annotation.dart';

class StationGenerator extends GeneratorForAnnotation<BeatStation> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement || !element.isEnum) {
      throw 'BeatStation can only be used on enums';
    }
    final contextType = annotation
        .read('contextType')
        .typeValue
        .getDisplayString(withNullability: false);
    final beats = await mapBeatAnnotations(element.name, element.fields);
    final commonBeats = await mapCommonBeatAnnotations(
      element.name,
      element,
    );
    final invokes = await mapInvokeAnnotations(element.name, element.fields);
    return [
      '// ignore_for_file: avoid_function_literals_in_foreach_calls',
      BeatStationBuilder(
        baseEnum: element,
        contextType: contextType,
        beats: beats,
        commonBeats: commonBeats,
        invokes: invokes,
      ).build(),
      BeatTransitionClassBuilder(
        beats: beats,
        commonBeats: commonBeats,
        baseEnum: element,
        contextType: contextType,
      ).build(),
      BeatStateBuilder(contextType: contextType, baseEnum: element).build(),
      BeatAnnotationVariablesBuilder([
        ...beats.values.reduce((value, element) => [...value, ...element]),
        ...commonBeats
      ]).build(),
      InvokeServicesBuilder(
        invokes: invokes,
        contextType: contextType,
        baseEnum: element,
      ).build(),
    ];
  }
}
