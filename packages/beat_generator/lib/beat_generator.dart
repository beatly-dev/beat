library beat_generator;

import 'package:beat_generator/src/station_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder beatMaker(BuilderOptions options) =>
    LibraryBuilder(StationGenerator(), generatedExtension: '.beat.dart');
