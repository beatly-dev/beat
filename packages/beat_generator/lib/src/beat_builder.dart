///! Some part of the code of this file is based on the following code:
///! - `source_gen` package
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'beat_tree/beat_tree_generator.dart';
import 'utils/source_gen.dart';

/// The main builder class for the generation of beat classes.
/// This class is responsible for the generation of depedency trees for the
/// beat related annotations.
///
/// `BeatBuilder` builds a dependency tree first and then build a code.
class BeatBuilder extends Builder {
  final String _header = defaultFileHeader;

  @override
  Map<String, List<String>> get buildExtensions =>
      validatedBuildExtensionsFrom(null, {
        '.dart': [
          '.beat.dart',
        ]
      });

  @override
  Future build(BuildStep buildStep) async {
    final resoliver = buildStep.resolver;
    final inputId = buildStep.inputId;
    if (!await resoliver.isLibrary(inputId)) {
      return;
    }

    /// TODO: Define GeneratorForAnnotation

    final lib = await buildStep.resolver.libraryFor(
      inputId,
      allowSyntaxErrors: false,
    );

    await _generateBeatlyCode(lib, buildStep);
  }

  Future _generateBeatlyCode(
    LibraryElement library,
    BuildStep buildStep,
  ) async {
    final generatedOutputs = await _generate(library, buildStep).toList();

    if (generatedOutputs.isEmpty) {
      return;
    }

    final outputId = buildStep.allowedOutputs.first;
    final contentBuffer = StringBuffer();

    contentBuffer.writeln(_header);

    final asset = buildStep.inputId;
    final name = nameOfPartial(library, asset, outputId);
    contentBuffer.writeln();

    contentBuffer
      ..write(languageOverrideForLibrary(library))
      ..writeln('part of $name;');
    final part = computePartUrl(buildStep.inputId, outputId);

    final libraryUnit =
        await buildStep.resolver.compilationUnitFor(buildStep.inputId);
    final hasLibraryPartDirectiveWithOutputUri =
        hasExpectedPartDirective(libraryUnit, part);
    if (!hasLibraryPartDirectiveWithOutputUri) {
      // TODO: Upgrade to error in a future breaking change?
      log.warning(
        '$part must be included as a part directive in '
        'the input library with:\n    part \'$part\';',
      );
      return;
    }
    for (var item in generatedOutputs) {
      contentBuffer
        ..writeln()
        ..writeln(defaultHeaderLine)
        ..writeAll(
          LineSplitter.split(item.generatorDescription)
              .map((line) => '// $line\n'),
        )
        ..writeln(defaultHeaderLine)
        ..writeln()
        ..writeln(item.output);
    }

    var genPartContent = contentBuffer.toString();

    try {
      genPartContent = defaultFormatter.format(genPartContent);
    } catch (e, stack) {
      log.severe(
        '''
An error `${e.runtimeType}` occurred while formatting the generated source for
  `${library.identifier}`
which was output to
  `${outputId.path}`.
This may indicate an issue in the generator, the input source code, or in the
source formatter.''',
        e,
        stack,
      );
    }

    await buildStep.writeAsString(outputId, genPartContent);
  }

  Stream<GeneratedOutput> _generate(
    LibraryElement library,
    BuildStep buildStep,
  ) async* {
    print("Generate");
    final libraryReader = LibraryReader(library);

    /// TODO: Run dependency builder
    final beatTree = BeatTreeBuilder();
    await beatTree.build(libraryReader, buildStep);

    /// TODO: Run generators
    final generators = <Generator>[];
    for (var i = 0; i < generators.length; ++i) {
      final gen = generators[i];

      var msg = 'Running $gen';
      if (generators.length > 1) {
        msg = '$msg - ${i + 1}/${generators.length}';
      }
      log.fine(msg);

      var createdUnit = await gen.generate(libraryReader, buildStep);

      if (createdUnit == null) {
        continue;
      }

      createdUnit = createdUnit.trim();
      if (createdUnit.isEmpty) {
        continue;
      }
      yield GeneratedOutput(gen, createdUnit);
    }
  }
}
