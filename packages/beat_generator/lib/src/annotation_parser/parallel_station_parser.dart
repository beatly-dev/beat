import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class ParallelStationParser {
  /// Returns set of root beat tree nodes.
  final ClassElement element;
  final ConstantReader annotation;
  final BuildStep buildStep;
  final LibraryReader library;

  ParallelStationParser({
    required this.element,
    required this.annotation,
    required this.buildStep,
    required this.library,
  });

  ParallelStationNode build() {
    final fields = element.fields;
    final stationId = annotation.stationId;
    final withFlutter = annotation.withFlutter;

    final vars = fields.map((field) {
      return field.name;
    }).toList();

    final Map<String, String> stationName = fields.fold({}, (map, field) {
      final varName = field.name;
      final type = field.type.getDisplayString(withNullability: false);
      map[varName] = type;
      return map;
    });

    return ParallelStationNode(
      id: stationId,
      name: element.name,
      vars: vars,
      stationName: stationName,
      withFlutter: withFlutter,
    );
  }
}

extension on ConstantReader {
  bool get withFlutter {
    return peek('withFlutter')?.boolValue ?? false;
  }

  String? get stationId {
    final id = peek('id')?.stringValue;
    return id;
  }
}

//     final initialStates = fields.map((field) {
//       if (!field.isConstantEvaluated) {
//         throw '''
// You must define initial state of the parallel station's children with static const.
// You didn't define it for ${element.name}.${field.name}.
// ''';
//       }
//       final value = field.computeConstantValue()!;
//       final initial = value.getField('_name')!.toStringValue()!;
//       return initial;
//     }).toList();