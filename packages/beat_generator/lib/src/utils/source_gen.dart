// THIS CODE IS FROM SOURCE_GEN
// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.source_gen file.
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

/// This code is from `source_gen` package
Map<String, List<String>> validatedBuildExtensionsFrom(
  Map<String, dynamic>? optionsMap,
  Map<String, List<String>> defaultExtensions,
) {
  final extensionsOption = optionsMap?.remove('build_extensions');
  if (extensionsOption == null) return defaultExtensions;

  if (extensionsOption is! Map) {
    throw ArgumentError(
      'Configured build_extensions should be a map from inputs to outputs.',
    );
  }

  final result = <String, List<String>>{};

  for (final entry in extensionsOption.entries) {
    final input = entry.key;
    if (input is! String || !input.endsWith('.dart')) {
      throw ArgumentError(
        'Invalid key in build_extensions option: `$input` '
        'should be a string ending with `.dart`',
      );
    }

    final output = entry.value;
    if (output is! String || !output.endsWith('.dart')) {
      throw ArgumentError(
        'Invalid output extension `$output`. It should be a '
        'string ending with `.dart`',
      );
    }

    result[input] = [output];
  }

  if (result.isEmpty) {
    throw ArgumentError('Configured build_extensions must not be empty.');
  }

  return result;
}

final defaultFormatter =
    DartFormatter(fixes: [StyleFix.singleCascadeStatements]);

final defaultHeaderLine = '// '.padRight(77, '*');

const partIdRegExpLiteral = r'[A-Za-z_\d-]+';

String nameOfPartial(LibraryElement element, AssetId source, AssetId output) {
  if (element.name.isNotEmpty) {
    return element.name;
  }

  assert(source.package == output.package);
  final relativeSourceUri =
      p.url.relative(source.path, from: p.url.dirname(output.path));
  return '\'$relativeSourceUri\'';
}

String languageOverrideForLibrary(LibraryElement library) {
  final override = library.languageVersion.override;
  return override == null
      ? ''
      : '// @dart=${override.major}.${override.minor}\n';
}

String computePartUrl(AssetId input, AssetId output) => p.url.joinAll(
      p.url.split(p.url.relative(output.path, from: input.path)).skip(1),
    );

bool hasExpectedPartDirective(CompilationUnit unit, String part) =>
    unit.directives
        .whereType<PartDirective>()
        .any((e) => e.uri.stringValue == part);

class GeneratedOutput {
  final String output;
  final String generatorDescription;

  GeneratedOutput(Generator generator, this.output)
      : assert(output.isNotEmpty),
        // assuming length check is cheaper than simple string equality
        assert(output.length == output.trim().length),
        generatorDescription = _toString(generator);

  static String _toString(Generator generator) {
    final output = generator.toString();
    if (output.endsWith('Generator')) {
      return output;
    }
    return 'Generator: $output';
  }
}
