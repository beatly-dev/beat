import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'beat_tree_generator/beat_tree_builder.dart';
import 'resources/beat_tree_resource.dart';
import 'utils/class_checker.dart';

class BeatNodeGenerator extends Generator {
  TypeChecker get typeChecker => TypeChecker.fromRuntime(BeatStation);
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final resource = await buildStep.fetchResource(inMemoryBeatTree);
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
      await resource.addNode(node);
    }
    return null;
  }
}

// _writeJson() {
    // final buffer = StringBuffer();
//       if (nodes.isEmpty) return null;

//     buffer.writeln('[');
//     buffer.writeln(nodes.join(',\n'));
//     buffer.writeln(']');

//     final libraryPath =
//         Uri.parse(library.element.identifier).path.split('/').last;
//     final filename = libraryPath.replaceAll(RegExp(r'.dart$'), '');
//     final outputLocation = '$entryPointDir/$filename.beat_tree.json';
//     final output = File(outputLocation);
//     var oldJson = '';
//     if (await output.exists()) {
//       oldJson = await output.readAsString();
//     } else {
//       await output.create(recursive: true);
//     }

//     final newJson = buffer.toString();
//     if (oldJson != newJson) {
//       print("Print out $outputLocation");
//       await output.writeAsString(newJson);
//     }
// }