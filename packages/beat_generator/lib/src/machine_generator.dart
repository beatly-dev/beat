import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'resources/station_data_resource.dart';

class BeatMachineGenerator extends GeneratorForAnnotation<Station> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement || element is! EnumElement) {
      throw 'BeatStation can only be used on enums';
    }
    final data = await buildStep.fetchResource(inMemoryStationData);

    return [];
  }
}
