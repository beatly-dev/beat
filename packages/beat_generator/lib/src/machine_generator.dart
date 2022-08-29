import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'flutter/consumer.dart';
import 'flutter/provider.dart';
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
      element: element,
      store: store,
    );

    final events = BeatEvents(
      element: element as EnumElement,
      store: store,
    );

    final provider = BeatProviderGenerator(element, store);
    final consumer = BeatConsumerGenerator(element, store);

    return [
      station.toString(),
      state.toString(),
      machine.toString(),
      events.toString(),
      provider.toString(),
      consumer.toString(),
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
    final machine = InheritedBeatMachine(
      element: element,
      store: store,
    );
    final provider = BeatProviderGenerator(element, store);
    final consumer = BeatConsumerGenerator(element, store);

    return [
      parallels.toString(),
      machine.toString(),
      provider.toString(),
      consumer.toString(),
    ];
  }
}
