library beat_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/machine_generator.dart';
import 'src/station_data_generator.dart';

Builder beatStationDataGenerator(BuilderOptions options) {
  return LibraryBuilder(
    StationDataGenerator(),
    generatedExtension: '.beat_tree.json',
  );
}

Builder beatMachineGenerator(BuilderOptions options) {
  final machineGenerator = BeatMachineGenerator();
  final parallelGenerator = ParallelMachineGenerator();
  return PartBuilder(
    [
      machineGenerator,
      parallelGenerator,
    ],
    '.beat.dart',
  );
}
