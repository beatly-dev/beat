library beat_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/beat_node_generator.dart';
import 'src/station_generator.dart';

Builder beatTreeMaker(BuilderOptions options) {
  return LibraryBuilder(
    BeatNodeGenerator(),
    generatedExtension: '.beat_tree.json',
  );
}

Builder beatMaker(BuilderOptions options) {
  final stationGenerator = StationGenerator();
  // final beatBuidler = BeatBuilder();
  // return BeatBuilder();
  // return LibraryBuilder(
  //   stationGenerator,
  //   generatedExtension: '.beat.dart',
  // );
  return PartBuilder(
    [
      // compoundGenerator,
      stationGenerator,
    ],
    '.beat.dart',
  );
}
