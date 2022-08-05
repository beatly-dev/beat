import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'helpers/beat_annotation_variables.dart';
import 'helpers/beat_state_class.dart';
import 'helpers/beat_station_class.dart';
import 'resources/beat_tree_resource.dart';

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
    final beatTree = await buildStep.fetchResource(inMemoryBeatTree);

    return [
      '// ignore_for_file: avoid_function_literals_in_foreach_calls',
      await BeatStationBuilder(
        baseEnum: element,
        beatTree: beatTree,
      ).build(),
      // BeatTransitionClassBuilder(
      //   baseEnum: element,
      //   beatTree: beatTree,
      // ).build(),
      await BeatStateBuilder(
        baseEnum: element,
        beatTree: beatTree,
      ).build(),
      // BeatAnnotationVariablesBuilder(
      //   beatTree: beatTree,
      // ).build(),
      // InvokeServicesBuilder(
      //   baseEnum: element,
      //   beatTree: beatTree,
      // ).build(),
      // await SenderClassBuilder(
      //   baseEnum: element,
      //   beatTree: beatTree,
      // ).build(),
      await GlobalBeatAnnotationVariablesBuilder(
        beatTree: beatTree,
        baseEnum: element,
      ).build(),
    ];
  }
}
