import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../utils/constant_reader.dart';
import '../utils/context.dart';
import '../utils/type_checker.dart';
import 'utils/beat_annotation.dart';
import 'utils/service_annotation.dart';

class StationParser {
  /// Returns set of root beat tree nodes.
  final ClassElement element;
  final ConstantReader annotation;
  final BuildStep buildStep;
  final LibraryReader library;

  StationParser({
    required this.element,
    required this.annotation,
    required this.buildStep,
    required this.library,
  });

  BeatStationNode build() {
    final fields = element.fields;
    final states =
        fields.where((e) => e.isEnumConstant).map((e) => e.name).toList();
    final stationId = annotation.stationId;
    final initialState = annotation.initialState;
    final initialContext = annotation.initialContext;
    var contextType = annotation.contextType;
    if (!annotation.isContextTypeRight) {
      throw '''
Initial context and context type mismatch.
- contextType: $contextType
- initialContext: $initialContext
''';
    }
    if (!isNullableContextType(contextType)) {
      contextType = '$contextType?';
    }
    final withFlutter = annotation.withFlutter;

    final beats = mapBeatAnnotations(element.name, [element], buildStep);

    final Map<String, String> substations =
        fields.fold({}, (substations, field) {
      if (substationChecker.hasAnnotationOf(field)) {
        final annotation = substationChecker.firstAnnotationOf(field)!;
        final reader = ConstantReader(annotation);
        final substationEnum = reader
            .peek('child')
            ?.typeValue
            .getDisplayString(withNullability: false);

        if (substationEnum == null) {
          throw '''
You should define substation enum. 
''';
        }
        substations[field.name] = substationEnum;
      }
      return substations;
    });

    final services =
        mapServicesAnnotations(element.name, element.fields, buildStep);

    final List<String> finalStates = fields.fold([], (list, field) {
      final checker = TypeChecker.fromRuntime(Final);
      if (checker.hasAnnotationOf(field)) {
        list.add(field.name);
      }
      return list;
    });

    var stationEntry = 'const OnEntry()';
    var stationExit = 'const OnExit()';
    final entryChecker = TypeChecker.fromRuntime(OnEntry);
    final exitChecker = TypeChecker.fromRuntime(OnExit);

    if (entryChecker.hasAnnotationOf(element)) {
      final annotation = element.metadata.firstWhere((meta) {
        return isAssignableFrom(entryChecker, meta);
      });
      stationEntry = 'const ${annotation.toSource().substring(1)}';
    }

    if (exitChecker.hasAnnotationOf(element)) {
      final annotation = element.metadata
          .firstWhere((element) => isAssignableFrom(exitChecker, element));
      stationExit = 'const ${annotation.toSource().substring(1)}';
    }

    final Map<String, String> stateEntry = fields.fold({}, (map, field) {
      if (entryChecker.hasAnnotationOf(field)) {
        final annotation = field.metadata.firstWhere((meta) {
          return isAssignableFrom(entryChecker, meta);
        });
        map[field.name] = 'const ${annotation.toSource().substring(1)}';
      } else {
        map[field.name] = 'const OnEntry()';
      }
      return map;
    });

    final Map<String, String> stateExit = fields.fold({}, (map, field) {
      if (exitChecker.hasAnnotationOf(field)) {
        final annotation = field.metadata.firstWhere((meta) {
          return isAssignableFrom(exitChecker, meta);
        });
        map[field.name] = 'const ${annotation.toSource().substring(1)}';
      } else {
        map[field.name] = 'const OnExit()';
      }
      return map;
    });

    final annotationSource = element.metadata
        .firstWhere((meta) {
          return isAssignableFrom(stationChecker, meta);
        })
        .toSource()
        .substring(1);

    return BeatStationNode(
      id: stationId,
      name: element.name,
      states: states,
      initialState: initialState ?? '${element.name}.${states.first}',
      initialContext: initialContext ?? 'null',
      contextType: contextType,
      substations: substations,
      beats: beats,
      services: services,
      finalState: finalStates,
      stationEntry: stationEntry,
      stationExit: stationExit,
      stateEntry: stateEntry,
      stateExit: stateExit,
      withFlutter: withFlutter,
      source: annotationSource,
    );
  }
}

bool isAssignableFrom(TypeChecker checker, ElementAnnotation annotation) {
  final annotationObj = annotation.computeConstantValue();

  if (annotationObj == null) return false;
  final type = annotationObj.type!;
  return checker.isAssignableFromType(type);
}

extension on ConstantReader {
  bool get isContextTypeRight {
    if (contextType == 'dynamic') {
      return true;
    }

    final initialType = peek('initialContext')
        ?.objectValue
        .type
        ?.getDisplayString(withNullability: false);

    return initialType == null || contextType == initialType;
  }

  String get contextType {
    return getTypeField(this, 'contextType')!;
  }

  String? get initialContext {
    final context = peek('initialContext');
    if (context == null) return null;
    final value = context.literalValue;
    if (value != null) return '$value';
    return context.objectValue.toString();
  }

  String? get initialState {
    final state = peek('initialState')?.objectValue.toString();
    return state;
  }

  bool get withFlutter {
    return peek('withFlutter')?.boolValue ?? false;
  }

  String? get stationId {
    final id = peek('id')?.stringValue;
    return id;
  }
}
