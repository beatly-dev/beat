import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations/beat_annotation.dart';
import '../annotations/beat_station_annotation.dart';
import '../annotations/invoke_annotation.dart';
import '../annotations/substation_annotation.dart';
import '../annotations/with_flutter_annotation.dart';

/// Dependency Builder
TypeChecker get beatChecker => TypeChecker.fromRuntime(Beat);
TypeChecker get beatStationChecker => TypeChecker.fromRuntime(Station);
TypeChecker get compoundChecker => TypeChecker.fromRuntime(Substation);
TypeChecker get invokeChecker => TypeChecker.fromRuntime(Invokes);
TypeChecker get parallelChecker => TypeChecker.fromRuntime(ParallelStation);

class BeatNodeBuilder {
  /// Returns set of root beat tree nodes.
  final ClassElement element;
  final ConstantReader annotation;
  final BuildStep buildStep;
  final LibraryReader library;

  BeatNodeBuilder({
    required this.element,
    required this.annotation,
    required this.buildStep,
    required this.library,
  });

  Future<BeatStationNode> build() async {
    final fields = element.fields;
    final states =
        fields.where((e) => e.isEnumConstant).map((e) => e.name).toList();
    final contextType = getBeatStationContextType(annotation);
    final beatConfigs =
        await mapBeatAnnotations(element.name, [element], buildStep);
    final substationConfigs =
        await mapSubstationAnnotations(element.name, element.fields, buildStep);
    final invokeConfigs =
        await mapInvokeAnnotations(element.name, element.fields, buildStep);
    final withFlutter = withFlutterChecker.hasAnnotationOf(element) ||
        (annotation.peek('withFlutter')?.boolValue ?? false);

    final node = BeatStationNode(
      BeatStationInfo(
        baseEnumName: element.name,
        contextType: contextType,
        states: states,
        withFlutter: withFlutter,
      ),
      beatConfigs: beatConfigs,
      children: {},
      substationConfigs: substationConfigs,
      invokeConfigs: invokeConfigs,
      parentBase: '',
      parentField: '',
    );

    return node;
  }
}
