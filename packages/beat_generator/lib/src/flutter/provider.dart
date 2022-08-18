import 'package:analyzer/dart/element/element.dart';

import '../models/state.dart';
import '../resources/beat_tree_resource.dart';
import '../utils/context.dart';
import '../utils/string.dart';

class BeatProviderGenerator {
  final ClassElement baseEnum;
  final BeatTreeSharedResource beatTree;

  BeatProviderGenerator(this.baseEnum, this.beatTree);
  late final node = beatTree.getNode(baseEnum.name);
  String get firstField =>
      baseEnum.fields.where((element) => element.isEnumConstant).first.name;
  String get enumName => baseEnum.name;
  String get className => '${enumName}Provider';
  String get stationName => toBeatStationClassName(enumName);
  String get beatName => toBeatStateClassName(enumName);
  String get senderName => toBeatSenderClassName(enumName);
  String get contextType => toContextType(node.info.contextType);
  ClassElement? get contextClass =>
      baseEnum.library.getClass(node.info.contextType);

  String contextTypeFields() {
    final context = contextClass;
    if (context == null) {
      return '';
    }
    final fields = context.fields;

    return fields
        .map(
          (field) =>
              '''final ${field.type.getDisplayString(withNullability: true).replaceAll(RegExp(r'[*?]'), '')}? \$\$${field.name};''',
        )
        .join();
  }

  String contextFieldInitializer() {
    final context = contextClass;
    if (context == null) {
      return '';
    }
    final fields = context.fields;
    return fields
        .map(
          (field) =>
              '''\$\$${field.name} = station.currentState.context?.${field.name}''',
        )
        .join(',');
  }

  String contextFieldConditions() {
    final context = contextClass;
    if (context == null) {
      return '';
    }
    final fields = context.fields;

    return fields
        .map(
          (field) => '''
if (dependencies.contains(r'context.${field.name}') && \$\$${field.name} != oldWidget.\$\$${field.name}) {
  return true;
}
''',
        )
        .join();
  }

  Future<String> stateMatcherFields() async {
    final nodes = await beatTree.getRelatedStations(enumName);
    final states = nodes.map((node) {
      final baseEnumName = node.info.baseEnumName;
      return node.info.states.map((state) => StateWrapper(baseEnumName, state));
    }).expand((states) => states);

    final matchers = states.map((state) {
      return toStateMatcher(
        state.baseName,
        state.fieldName,
        state.baseName == enumName,
      );
    });

    /// TODO:
    /// If a user asks for a parallel state => not yet supported
    return matchers.map((matcher) {
      return '''
final bool $matcher;
      ''';
    }).join();
  }

  Future<String> stateMatcherInitializer() async {
    final nodes = await beatTree.getRelatedStations(enumName);
    final states = nodes.map((node) {
      final baseEnumName = node.info.baseEnumName;
      return node.info.states.map((state) => StateWrapper(baseEnumName, state));
    }).expand((states) => states);

    final matchers = states.map((state) {
      return toStateMatcher(
        state.baseName,
        state.fieldName,
        state.baseName == enumName,
      );
    });

    /// TODO:
    /// If a user asks for a parallel state => not yet supported
    return matchers.map((matcher) {
      return '''
$matcher = station.currentState.$matcher
      ''';
    }).join(',');
  }

  Future<String> stateMatcherConditions() async {
    final nodes = await beatTree.getRelatedStations(enumName);
    final states = nodes.map((node) {
      final baseEnumName = node.info.baseEnumName;
      return node.info.states.map((state) => StateWrapper(baseEnumName, state));
    }).expand((states) => states);

    final matchers = states.map((state) {
      return toStateMatcher(
        state.baseName,
        state.fieldName,
        state.baseName == enumName,
      );
    });

    /// TODO:
    /// If a user asks for a parallel state => not yet supported
    return matchers.map((matcher) {
      return '''
if (dependencies.contains(r'$matcher') && $matcher != oldWidget.$matcher) {
  return true;
}
      ''';
    }).join();
  }

  Future<String> toProvider() async {
    if (!node.info.withFlutter) {
      return '';
    }

    return '''
class $className extends BeatStationScope<${contextType.replaceAll(r'?', '')}> {
  $className({
    required super.child,
    this.firstState = $enumName.$firstField,
    this.initialContext,
    super.beforeDispose,
    super.beforeStart,
    super.key,
  });

  final $enumName firstState;
  final $contextType initialContext;

  @override
  late final $stationName station = $stationName(
    firstState: firstState,
    initialContext: initialContext,
  );

  @override
  ${className}State createState() => ${className}State();
}

class ${className}State extends BeatStationScopeState<$className> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.station.stateStream,
      builder: (context, snapshot) {
        return CounterProviderScope(
          station: widget.station,
          child: widget.child,
        );
      },
    );
  }
}

class ${className}Scope extends BeatStationProviderScope {
  ${className}Scope({
    required super.child,
    required this.station,
    super.key,
  })  : ${[
      'state = station.currentState',
      'enumState = station.currentState.state',
      'context = station.currentState.context',
      contextFieldInitializer(),
      await stateMatcherInitializer()
    ].where((e) => e.isNotEmpty).join(',')};

  final $stationName station;
  final $beatName state;
  final $enumName enumState;
  final $contextType context;
  ${contextTypeFields()}
  ${await stateMatcherFields()}

  static ${className}Scope of(
    BuildContext context, {
    Object? dependency,
  }) {
    return BeatStationProviderScope.of<${className}Scope>(
      context,
      dependency: dependency,
    );
  }

  @override
  bool updateShouldNotify(
    covariant ${className}Scope oldWidget,
  ) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant ${className}Scope oldWidget,
    Set<Object> dependencies,
  ) {
    if (dependencies.isNotEmpty && station != oldWidget.station) {
      return true;
    }

    if (dependencies.contains('currentState') && state != oldWidget.state) {
      return true;
    }
    if (dependencies.contains('enumState') &&
        enumState != oldWidget.enumState) {
      return true;
    }

    if (dependencies.contains('context') && context != oldWidget.context) {
      return true;
    }
    ${contextFieldConditions()}

    ${await stateMatcherConditions()}
    return false;
  }
}

''';
  }
}
