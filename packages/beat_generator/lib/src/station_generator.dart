import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations/beat_annotation.dart';
import 'annotations/beat_station_annotation.dart';
import 'annotations/invoke_annotation.dart';
import 'annotations/substation_annotation.dart';
import 'helpers/beat_annotation_variables.dart';
import 'helpers/beat_state_class.dart';
import 'helpers/beat_transition_class.dart';
import 'helpers/invoke_services.dart';
import 'helpers/sender_class.dart';
import 'helpers/station_class.dart';
import 'resources/beat_tree_resource.dart';

class StationGenerator extends GeneratorForAnnotation<BeatStation> {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    buildStep.fetchResource(inMemoryBeatTree);
    return super.generate(library, buildStep);
  }

  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement || !element.isEnum) {
      throw 'BeatStation can only be used on enums';
    }
    final contextType = getBeatStationContextType(annotation);
    final beats =
        await mapBeatAnnotations(element.name, element.fields, buildStep);
    final commonBeats = (await mapBeatAnnotations(
      element.name,
      [element],
      buildStep,
    ))
        .values
        .expand((element) => element)
        .toList();
    final invokes =
        await mapInvokeAnnotations(element.name, element.fields, buildStep);
    final compounds = (await mapSubstationAnnotations(
      element.name,
      element.fields,
      buildStep,
    ))
        .values
        .expand((element) => element)
        .toList();

    return [
      '// ignore_for_file: avoid_function_literals_in_foreach_calls',
      BeatStationBuilder(
        baseEnum: element,
        contextType: contextType,
        beats: beats,
        commonBeats: commonBeats,
        invokes: invokes,
        compounds: compounds,
      ).build(),
      BeatTransitionClassBuilder(
        beats: beats,
        commonBeats: commonBeats,
        baseEnum: element,
        contextType: contextType,
      ).build(),
      BeatStateBuilder(contextType: contextType, baseEnum: element).build(),
      BeatAnnotationVariablesBuilder(
        [...beats.values.expand((element) => element), ...commonBeats],
      ).build(),
      InvokeServicesBuilder(
        invokes: invokes,
        contextType: contextType,
        baseEnum: element,
      ).build(),
      SenderClassBuilder(
        beats: beats,
        commonBeats: commonBeats,
        baseName: element.name,
        compounds: compounds,
      ).build(),
    ];
  }
}
