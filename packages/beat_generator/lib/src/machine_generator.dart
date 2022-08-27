import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator/events.dart';
import 'generator/machine.dart';
import 'generator/parallel_station.dart';
import 'generator/state.dart';
import 'generator/station.dart';
import 'resources/station_data.dart';

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
    final store = await buildStep.fetchResource(inMemoryStationData);

    final station = InheritedBeatStation(
      element: element as EnumElement,
      store: store,
    );

    final state = InheritedBeatState(
      element: element as EnumElement,
      store: store,
    );

    final machine = InheritedBeatMachine(
      element: element as EnumElement,
      store: store,
    );

    final events = BeatEvents(
      element: element as EnumElement,
      store: store,
    );

    return [
      station.toString(),
      state.toString(),
      machine.toString(),
      events.toString(),
    ];
  }
}

class ParallelMachineGenerator extends GeneratorForAnnotation<ParallelStation> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement || element is EnumElement) {
      throw 'BeatStation can only be used on class';
    }

    final store = await buildStep.fetchResource(inMemoryStationData);
    final parallels = InheritedParallelStation(element: element, store: store);

    return [
      parallels.toString(),
    ];
  }
}
