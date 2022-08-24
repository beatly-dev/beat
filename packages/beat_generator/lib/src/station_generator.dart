import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'flutter/consumer.dart';
import 'flutter/provider.dart';
import 'helpers/beat_annotation_variables.dart';
import 'helpers/beat_state_class.dart';
import 'helpers/beat_station_class.dart';
import 'helpers/beat_transition_class.dart';
import 'helpers/invoke_services.dart';
import 'helpers/sender_class.dart';
import 'resources/beat_tree_resource.dart';

class StationGenerator extends GeneratorForAnnotation<Station> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement || element is! EnumElement) {
      throw 'BeatStation can only be used on enums';
    }
    final beatTree = await buildStep.fetchResource(inMemoryBeatTree);

    return [
      '// ignore_for_file: avoid_function_literals_in_foreach_calls',
      '// ignore_for_file: unused_field',
      '// ignore_for_file: unused_element',
      await BeatStationBuilder(
        baseEnum: element,
        beatTree: beatTree,
      ).build(),
      await BeatTransitionClassBuilder(
        baseEnum: element,
        beatTree: beatTree,
      ).build(),
      await BeatStateBuilder(
        baseEnum: element,
        beatTree: beatTree,
      ).build(),
      await SenderClassBuilder(
        baseEnum: element,
        beatTree: beatTree,
      ).build(),
      await GlobalBeatAnnotationVariablesBuilder(
        beatTree: beatTree,
        baseEnum: element,
      ).build(),
      await GlobalInovkeAnnotationVariablesBuilder(
        beatTree: beatTree,
        baseEnum: element,
      ).build(),
      await BeatProviderGenerator(
        element,
        beatTree,
      ).toProvider(),
      await BeatConsumerGenerator(element, beatTree).toConsumer(),
    ];
  }
}
