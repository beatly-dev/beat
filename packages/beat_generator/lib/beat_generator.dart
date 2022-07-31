library beat_generator;

import 'package:build/build.dart';

import 'src/beat_builder.dart';
import 'src/compound_generator.dart';
import 'src/station_generator.dart';

Builder beatMaker(BuilderOptions options) {
  final compoundGenerator = CompoundGenerator();
  final stationGenerator = StationGenerator();
  final beatBuidler = BeatBuilder();
  return BeatBuilder();
  // return PartBuilder(
  //   [
  //     compoundGenerator,
  //     stationGenerator,
  //   ],
  //   '.beat.dart',
  // );
}
