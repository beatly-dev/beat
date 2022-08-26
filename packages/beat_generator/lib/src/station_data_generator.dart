import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation_parser/parallel_station_parser.dart';
import 'annotation_parser/station_parser.dart';
import 'resources/station_data_resource.dart';
import 'utils/class_checker.dart';
import 'utils/type_checker.dart';

class StationDataGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final globalStationStore =
        await buildStep.fetchResource(inMemoryStationData);
    final output = _outputFile(library);
    final localStationStore = <String>[];

    var oldJson = '';

    // remove all nodes from the old beat tree to prevent unwanted state.
    if (await output.exists()) {
      oldJson = await output.readAsString();
      final oldData = jsonDecode(oldJson) as List;
      _removeOldData(globalStationStore, oldData.whereType<String>().toList());
    }

    /// process normal station
    for (var annotatedElement in library.annotatedWith(stationChecker)) {
      // annotated element: An enum class
      final element = annotatedElement.element;

      if (!isEnumClass(element)) {
        continue;
      }

      // annotation: [BeatStation]
      final annotation = annotatedElement.annotation;

      final builder = StationParser(
        element: element as ClassElement,
        annotation: annotation,
        buildStep: buildStep,
        library: library,
      );

      final node = builder.build();
      globalStationStore.addStation(station: node);
      localStationStore.add(node.name);
    }

    /// process parallel station
    for (var annotatedElement in library.annotatedWith(parallelChecker)) {
      // annotated element: An enum class
      final element = annotatedElement.element;

      // annotation: [BeatStation]
      final annotation = annotatedElement.annotation;

      final builder = ParallelStationParser(
        element: element as ClassElement,
        annotation: annotation,
        buildStep: buildStep,
        library: library,
      );

      final node = builder.build();
      await globalStationStore.addStation(parallel: node);
      localStationStore.add(node.name);
    }

    _writeJson(library, localStationStore, oldJson);
    return null;
  }

  _removeOldData(StationDataStore beatTree, List<String> oldData) {
    for (final item in oldData) {
      beatTree.removeStation(item);
    }
  }

  _writeJson(
    LibraryReader library,
    List<String> nodes,
    String oldJson,
  ) async {
    if (nodes.isEmpty) return null;
    final newJson = jsonEncode(nodes);
    if (oldJson == newJson) {
      return;
    }

    final output = _outputFile(library);

    if (!await output.exists()) {
      await output.create(recursive: true);
    }

    await output.writeAsString(newJson);
  }

  _outputFile(LibraryReader library) {
    final libraryPath =
        Uri.parse(library.element.identifier).path.split('/').last;
    final filename = libraryPath.replaceAll(RegExp(r'.dart$'), '');
    final outputLocation = '$beatEntryPointDir/$filename.beat_data.json';

    final output = File(outputLocation);
    return output;
  }
}
