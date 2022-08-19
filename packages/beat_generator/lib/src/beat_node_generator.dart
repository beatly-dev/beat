import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:source_gen/source_gen.dart';

import 'beat_tree_generator/beat_tree_builder.dart';
import 'resources/beat_tree_resource.dart';
import 'utils/class_checker.dart';

class BeatNodeGenerator extends Generator {
  TypeChecker get typeChecker => TypeChecker.fromRuntime(BeatStation);
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final beatTree = await buildStep.fetchResource(inMemoryBeatTree);
    final localNodes = <BeatStationNode>[];
    final libraryPath =
        Uri.parse(library.element.identifier).path.split('/').last;
    final filename = libraryPath.replaceAll(RegExp(r'.dart$'), '');
    final outputLocation = '$entryPointDir/$filename.beat_tree.json';
    final output = File(outputLocation);
    var oldJson = '';

    // remove all nodes from the old beat tree to prevent unwanted state.
    if (await output.exists()) {
      oldJson = await output.readAsString();
      final oldNodes = jsonDecode(oldJson) as List<dynamic>;
      for (final item in oldNodes) {
        final node = BeatStationNode.fromJson(item);
        beatTree.removeNode(node);
      }
    }

    for (var annotatedElement in library.annotatedWith(typeChecker)) {
      // annotated element: An enum class
      final element = annotatedElement.element;

      if (!isEnumClass(element)) {
        continue;
      }

      // annotation: [BeatStation]
      final annotation = annotatedElement.annotation;

      final builder = BeatNodeBuilder(
        element: element as ClassElement,
        annotation: annotation,
        buildStep: buildStep,
        library: library,
      );

      final node = await builder.build();
      await beatTree.addNode(node);
      localNodes.add(node);
    }
    _writeJson(library, buildStep, localNodes, oldJson);
    return null;
  }

  _writeJson(
    LibraryReader library,
    BuildStep buildStep,
    List<BeatStationNode> nodes,
    String oldJson,
  ) async {
    final buffer = StringBuffer();
    if (nodes.isEmpty) return null;
    buffer.writeln('[');
    buffer.writeln(nodes.map(jsonEncode).join(',\n'));
    buffer.writeln(']');
    final newJson = buffer.toString();
    if (oldJson == newJson) {
      return;
    }

    final libraryPath =
        Uri.parse(library.element.identifier).path.split('/').last;
    final filename = libraryPath.replaceAll(RegExp(r'.dart$'), '');
    final outputLocation = '$entryPointDir/$filename.beat_tree.json';

    final output = File(outputLocation);
    if (!await output.exists()) {
      await output.create(recursive: true);
    }

    await output.writeAsString(newJson);
  }
}
