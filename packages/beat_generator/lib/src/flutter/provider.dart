import 'dart:async';

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
      baseEnum.library.getClass(node.info.contextType) ??
      baseEnum.library.units
          .firstWhere(
            (element) => element.getClass(node.info.contextType) != null,
          )
          .getClass(node.info.contextType);

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

  Future<String> wrapProvider(String provider) async {
    final children = await beatTree.getRelatedStations(enumName);
    final directChildren =
        children.where((element) => element.parentBase == enumName);
    final wrapped = directChildren.fold(provider, (code, node) {
      final name = node.info.baseEnumName;
      return '''
${name}Provider(
  baseStation: widget.station.${toSubstationFieldName(name)},
  child: $provider, 
)
''';
    });
    return wrapped;
  }

  Future<String> toProvider([bool force = false]) async {
    if (!force && !node.info.withFlutter) {
      return '';
    }
    final children = (await beatTree.getRelatedStations(enumName))
        .where(
          (element) =>
              element.info.baseEnumName != enumName &&
              !element.info.withFlutter,
        )
        .map((node) => node.info.baseEnumName)
        .toList();

    if (children.isNotEmpty) {
      throw '***** You should annotate your substate enums with @withFlutter *****'
          '\nMissing children: $children';
    }

    return '''

class $className extends BeatStationScope<${contextType.replaceAll(r'?', '')}> {
  $className({
    required super.child,
    this.firstState = $enumName.$firstField,
    this.initialContext,
    this.beforeDispose,
    this.beforeStart,
    super.key,
    this.baseStation,
  });

  final $enumName firstState;
  final $contextType initialContext;

  @override
  final void Function(covariant ${enumName}BeatStation station)? beforeStart;
  @override
  final void Function(covariant ${enumName}BeatStation station)? beforeDispose;

  final $stationName? baseStation;

  @override
  bool get autoStart => baseStation == null;

  @override
  $stationName get station => baseStation ?? _internalStation;

  late final $stationName _internalStation = $stationName(
    firstState: firstState,
    initialContext: initialContext,
  );

  @override
  ${className}State createState() => ${className}State();
}

class ${className}State extends BeatStationScopeState<$className> {
  @override
  Widget build(BuildContext context) {
    return ${await wrapProvider(
      '''
    StreamBuilder(
      stream: widget.station.stateStream,
      builder: (context, snapshot) {
        return ${className}Scope(
          station: widget.station,
          child: widget.child,
        );
      },
    )
''',
    )};
  }
}

class ${className}Scope extends BeatStationProviderScope {
  ${className}Scope({
    required super.child,
    required this.station,
    super.key,
  });

  final $stationName station;
  final Map<String, dynamic> _partOfMaps = {};
  final Map<String, dynamic> _partOfSelectorMaps = {};

  static ${className}Scope of(
    BuildContext context, {
    Object? dependency,
  }) {
    return BeatStationProviderScope.of<${className}Scope>(
      context,
      dependency: dependency,
    );
  }

  T watch<T>(String key, T Function(${enumName}BeatStation station) selector) {
    final value = selector(station);
    _partOfMaps.addAll({key: value});
    _partOfSelectorMaps.addAll({key: selector});
    return value;
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
    final deps = dependencies.where((element) => element != '_readonly_');
    if (deps.isEmpty) {
      return false;
    }

    if (station != oldWidget.station) {
      return true;
    }

    // if it depdens on station, every changes should notify
    if (deps.any((d) => d == 'station')) {
      return true;
    }

    final watched = deps.where((d) => d != 'station');
    final changed = watched.any((d) {
      if (d == 'station' || d is! String) return false;
      final oldValue = oldWidget._partOfMaps[d];
      final newValue = oldWidget._partOfSelectorMaps[d]?.call(station);
      _partOfMaps[d] = newValue;
      _partOfSelectorMaps[d] = oldWidget._partOfSelectorMaps[d];
      return oldValue != newValue;
    });

    return changed;
  }
}

''';
  }
}
