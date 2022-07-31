import 'dart:async';

import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'beat_tree.dart';

/// Dependency Builder

class BeatTreeBuilder {
  TypeChecker get beatChecker => TypeChecker.fromRuntime(Beat);
  TypeChecker get beatStationChecker => TypeChecker.fromRuntime(BeatStation);
  TypeChecker get compoundChecker => TypeChecker.fromRuntime(Compound);
  TypeChecker get invokeChecker => TypeChecker.fromRuntime(Invokes);
  TypeChecker get parallelChecker => TypeChecker.fromRuntime(Parallel);

  /// Returns set of root beat tree nodes.
  Future<List<BeatTree>> build(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    final beatStationAnnotated = library.annotatedWith(beatStationChecker);
    final beatAnnotated = library.annotatedWith(beatChecker);
    final comopundAnnotated = library.annotatedWith(compoundChecker);
    final invokesAnnotated = library.annotatedWith(invokeChecker);
    final parallelAnnotated = library.annotatedWith(parallelChecker);

    print("Beatstation ${beatStationAnnotated.length}");
    print("Beat ${beatAnnotated.length}");
    print("Compound ${comopundAnnotated.length}");
    print("Invokes ${invokesAnnotated.length}");
    print("Parallel ${parallelAnnotated.length}");

    // final values = <String>{};
    // for (var annotatedElement in library.annotatedWith(typeChecker)) {
    //   final generatedValue = generateForAnnotatedElement(
    //     annotatedElement.element,
    //     annotatedElement.annotation,
    //     buildStep,
    //   );
    //   await for (var value in normalizeGeneratorOutput(generatedValue)) {
    //     assert(value.length == value.trim().length);
    //     values.add(value);
    //   }
    // }

    // return values.join('\n\n');
    return [];
  }
}
