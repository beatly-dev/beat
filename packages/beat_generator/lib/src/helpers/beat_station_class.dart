import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../constants/field_names.dart';
import '../resources/beat_tree_resource.dart';
import '../utils/context.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';
import 'execute_actions.dart';

/// Top-level class
///
/// # fields
///
/// - history: `List<BeatState>`
/// - initialState: `BeatState`
/// - currentState: `BeatState`
/// - nextEvents: `List<String>`
/// - done: `bool`
///
/// # methods
///
/// - ${event}

class BeatStationBuilder {
  final ClassElement baseEnum;
  final BeatTreeSharedResource beatTree;

  final buffer = StringBuffer();

  BeatStationBuilder({
    required this.baseEnum,
    required this.beatTree,
  });

  Future<String> build() async {
    final name = baseEnum.name;
    final beatStationClassName = toBeatStationClassName(name);
    final node = beatTree.getNode(name);
    final substations = await beatTree.getRelatedStations(
      baseEnum.name,
    );
    await _createConstructor(substations);
    await _createInitialStateField();
    _createStationStatusHandler();
    await _createStateHistoryField();
    await _createSubstationFields(substations);

    await _createEventlessHandler();

    _createTransitionFields(node);
    _createCommonBeatTransitions(node);
    _createInvokeServices(node);
    await _createCurrentState();
    await _createSetState();
    await _createSetContext(node.info.contextType);
    _createReset();
    _createSender();

    /// TODO:
    /// - nested listeners
    _createListenersFields(substations);
    _createListenersMethods(substations);
    _createNotifyListenersMethod(substations);
    _createExecMethods(substations);
    _createMapMethods(substations);
    return createClass(
      '$beatStationClassName extends BeatStationBase',
      buffer.toString(),
    );
  }

  _createEventlessHandler() async {
    final name = baseEnum.name;
    final nodes = await beatTree.getRelatedStations(name);

    /// create eventless handler
    final eventless = nodes.fold<List<BeatConfig>>([], (configs, node) {
      final beatConfigs = node.beatConfigs.values.expand((element) => element);

      configs.addAll(
        beatConfigs.where((config) {
          return config.eventless;
        }),
      );

      return configs;
    });

    final mappedEventless =
        eventless.fold<Map<String, List<BeatConfig>>>({}, (map, config) {
      final state = config.fromField;
      map[state] ??= [];
      map[state]!.add(config);
      return map;
    });

    final body = mappedEventless.keys.map((state) {
      final configs = mappedEventless[state]!;
      final matcher = toStateMatcher(name, state, name == baseEnum.name);
      final block = configs.map((config) {
        final beatname = toBeatAnnotationVariableName(
          config.fromBase,
          config.fromField,
          config.event,
          config.toBase,
          config.toField,
        );
        return '''
addDelayed($beatname.after, () {
  if ($currentStateFieldName.$matcher) {
    $setStateMethodName(${config.toBase}.${config.toField});
  }
});
''';
      }).join();
      return '''
if ($currentStateFieldName.$matcher) {
  $block
}
''';
    }).join(' else ');

    buffer.writeln(
      '''
void $eventlessHandlerMethodName() {
  $body
}
''',
    );
  }

  _createSender() {
    final senderClassName = toBeatSenderClassName(baseEnum.name);
    buffer.writeln(
      '''
$senderClassName get send => $senderClassName(this);
''',
    );
  }

  _createStationStatusHandler() {
    buffer.writeln(
      '''
bool $stationStartedFieldName;
start() {
  clearState();
  $stationStartedFieldName = true;
}

stop() {
  $stationStartedFieldName = false;
}
''',
    );
  }

  _createSubstationFields(List<BeatStationNode> nestedStations) async {
    final directSubstations =
        nestedStations.where((element) => element.parentBase == baseEnum.name);
    for (final substation in directSubstations) {
      final name = substation.info.baseEnumName;
      final substationClassName = toBeatStationClassName(name);
      final substationFieldName = toSubstationFieldName(name);
      buffer.writeln(
        '''
final $substationClassName $substationFieldName = $substationClassName(started: false);
''',
      );
    }
  }

  _createConstructor(List<BeatStationNode> nestedStations) async {
    final baseEnumName = baseEnum.name;
    final stationNode = beatTree.getNode(baseEnumName);
    final firstState = stationNode.info.states.first;
    final contextType = stationNode.info.contextType;
    final beatStationClassName = toBeatStationClassName(baseEnumName);
    final stateClass = toBeatStateClassName(baseEnumName);
    final firstStateArg = 'firstState';
    final initialContextArg = 'initialContext';
    buffer.writeln('$beatStationClassName({');
    buffer
        .writeln('  $baseEnumName $firstStateArg = $baseEnumName.$firstState,');
    buffer.writeln(
      '${toContextType(contextType)} $initialContextArg,',
    );
    buffer.writeln('this.$stationStartedFieldName = true,');
    buffer.writeln('})');

    /// additional initializers
    buffer.writeln(':');

    buffer.writeln(
      [
        /// initial state
        '''
$initialStateFieldName = $stateClass(
  $stateFieldName: $firstStateArg,
  $contextFieldName: $initialContextArg,
)
''',
      ].join(','),
    );

    /// [[ constructor body
    buffer.writeln('{');
    // first history
    buffer.writeln(
      '''
$stateHistoryFieldName.add($initialStateFieldName);
''',
    );
    buffer.writeln(
      '''
$initialStateFieldName._initialize(this);
''',
    );
    buffer.writeln('}');

    /// ]] constructor body
  }

  _createStateHistoryField() async {
    final stateClass = toBeatStateClassName(baseEnum.name);
    buffer.writeln(
      '''
final List<$stateClass> $stateHistoryFieldName = [];
''',
    );
  }

  _createInitialStateField() async {
    final stateClass = toBeatStateClassName(baseEnum.name);
    buffer.writeln(
      'final $stateClass $initialStateFieldName;',
    );
  }

  _createCurrentState() async {
    final stateClass = toBeatStateClassName(baseEnum.name);
    buffer.writeln(
      '$stateClass get $currentStateFieldName => $stateHistoryFieldName.last;',
    );
  }

  _createSetState() async {
    /// TODO
    /// - set state for substations
    /// - set state for parallel stations
    final stateClassName = toBeatStateClassName(baseEnum.name);
    buffer.writeln(
      '''
void $setStateMethodName(dynamic state) {
  assert(state is Enum || state is List<Enum>);
  clearDelayed();
  final nextState = $stateClassName(state: state, context: currentState.context)..$stateInitializerMethodName(this);
  $stateHistoryFieldName.add(nextState);
  $notifyListenersMethodName();
  _invokeServices();
  $eventlessHandlerMethodName();
}
''',
    );
  }

  _createSetContext(String contextType) async {
    /// TODO
    /// - set context for substations
    /// - set context for parallel stations
    final stateClassName = toBeatStateClassName(baseEnum.name);
    final realContextType = toContextType(contextType);
    buffer.writeln(
      '''
void $setContextMethodName($realContextType context) {
  final nextState = $stateClassName(state: currentState.state, context: context)..$stateInitializerMethodName(this);
  $stateHistoryFieldName.add(nextState);
  // $notifyListenersMethodName();
}
''',
    );
  }

  _createInvokeServices(BeatStationNode node) {
    final invokes = node.invokeConfigs;
    final baseName = baseEnum.name;

    final body =
        invokes.keys.where((state) => invokes[state]!.isNotEmpty).map((state) {
      final config = invokes[state]![0];
      final varName = toInvokeVariableName(config);

      /// TODO: nested transition on done/error
      return '''
if (currentState.state == ${config.stateBase}.${config.stateField}) {
  for (final invoke in $varName.invokes) {
    if (invoke is InvokeFuture) {
      (() async {
        final onDone = invoke.onDone;
        final onError = invoke.onError;
        try {
          final result = await invoke.invokeWith(currentState, '');
          for (final action in onDone.actions) {
            ${createActionExecutor('action', 'EventData(event:"invoke", data: result)', true)}
          }
          if (onDone.to is $baseName) {
            _setState(onDone.to);
          }
        } catch (_) {
          for (final action in onError.actions) {
            ${createActionExecutor('action', 'EventData(event:"invoke", data: null)', true)}
          }
          if (onError.to is $baseName) {
            _setState(onError.to);
          }
        }
      })();
    } else {
      invoke.invokeWith(currentState.state, currentState.context, '');
    }
  }
}
''';
    }).join(' else ');

    buffer.writeln(
      '''
_invokeServices() async {
  $body
}
''',
    );
  }

  void _createReset() {
    buffer.writeln(
      '''
  void resetState() {
    $stateHistoryFieldName.add(initialState);
    $notifyListenersMethodName();
    _invokeServices();
  }

  void clearState() {
    $stateHistoryFieldName.clear();
    resetState();
  }
''',
    );
  }

  void _createCommonBeatTransitions(BeatStationNode node) {
    final baseName = node.info.baseEnumName;
    final commonBeats = (node.beatConfigs[baseName] ?? [])
        .where((element) => !element.eventless);
    for (final config in commonBeats) {
      buffer.writeln(
        '''
void ${toActionExecutorMethodName(config.event)}(EventData eventData) {
  for (final action in ${toBeatAnnotationVariableName(config.fromBase, config.fromField, config.event, config.toBase, config.toField)}.actions) {
    ${createActionExecutor('action', 'eventData', true)}
  }
}
''',
      );
      buffer.writeln(
        '''
\$${config.event}<Data>({Data? data, Duration after = const Duration(milliseconds: 0)}) {
  if (after.inMicroseconds > 0) {
    return addDelayed(after, () {
      \$${config.event}(data: data);
    });
  }
  ${toActionExecutorMethodName(config.event)}(EventData(event: '${config.event}', data: data));
  _setState($baseName.${config.toField});
}
''',
      );
    }
  }

  void _createTransitionFields(BeatStationNode node) {
    final states = node.info.states;
    final baseName = node.info.baseEnumName;
    for (final state in states) {
      final beatConfigs = (node.beatConfigs[state] ?? [])
          .where((element) => !element.eventless);
      buffer.writeln(
        '''${toBeatTransitionBaseClassName(baseName, state)} get ${toTransitionFieldName(state)} {
          if (currentState.state == $baseName.$state) {
            return ${toBeatTransitionRealClassName(baseName, state)}(${beatConfigs.isEmpty ? '' : 'this'});
          }
          return const ${toBeatTransitionDummyClassName(baseName, state)}();
        }''',
      );
    }
  }

  _createListenersFields(List<BeatStationNode> nestedStations) {
    buffer.writeln(
      '''
final _listeners = <Function>[];
''',
    );

    for (final station in nestedStations) {
      for (final state in station.info.states) {
        final name =
            '${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}';
        buffer.writeln(
          '''
final ${toListenerFieldName(name)} = <Function>[];
''',
        );
      }
    }
  }

  void _createNotifyListenersMethod(List<BeatStationNode> nestedStations) {
    buffer.writeln(
      '''
  void _notifyListeners() {
    _listeners.forEach((listener) => listener());
    ''',
    );

    buffer.writeln(
      nestedStations.map((station) {
        return station.info.states.map((state) {
          final matcher = toStateMatcher(
            station.info.baseEnumName,
            state,
            station.info.baseEnumName == baseEnum.name,
          );
          final name =
              '${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}';
          return '''
if (currentState.$matcher) {
    ${toListenerFieldName(name)}.forEach((listener) => listener());
}
''';
        }).join('else ');
      }).join('else '),
    );
    buffer.writeln(
      '''
  }
''',
    );
  }

  _createListenersMethods(List<BeatStationNode> nestedStations) {
    buffer.writeln(
      '''
void addListener(Function() callback) {
  _listeners.add(callback);
}
''',
    );
    buffer.writeln(
      '''
void removeListener(Function() callback) {
  _listeners.remove(callback);
}
''',
    );
    for (final station in nestedStations) {
      for (final state in station.info.states) {
        final name =
            '${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}';
        buffer.writeln(
          '''
  void ${toAddListenerMethodName(name)}(Function() callback) {
    ${toListenerFieldName(name)}.add(callback);
  }
  void ${toRemoveListenerMethodName(name)}(Function() callback) {
    ${toListenerFieldName(name)}.remove(callback);
  }
''',
        );
      }
    }
  }

  _createExecMethods(List<BeatStationNode> nestedStations) {
    final arguments = [
      ...nestedStations.map(
        (station) => station.info.states
            .map(
              (state) => '''
Function()? on${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}
''',
            )
            .join(','),
      ),
      'required Function() orElse',
    ].join(', ');

    final body = [
      ...nestedStations.map(
        (station) => station.info.states
            .map(
              (state) => '''
if (currentState.${toStateMatcher(station.info.baseEnumName, state, station.info.baseEnumName == baseEnum.name)}) {
  return on${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}?.call() ?? orElse();
}
''',
            )
            .join('else '),
      )
    ].join('else ');
    // common exec method
    buffer.writeln(
      '''
exec({
  $arguments,
}) {
  $body
  return orElse();
}
''',
    );

    for (final station in nestedStations) {
      for (final state in station.info.states) {
        buffer.writeln(
          '''
  void ${toExecMethodName('${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}')}(Function() callback) {
    if (currentState.${toStateMatcher(station.info.baseEnumName, state, station.info.baseEnumName == baseEnum.name)}) {
      callback();
    }
  }
''',
        );
      }
    }
  }

  void _createMapMethods(List<BeatStationNode> nestedStations) {
    final arguments = [
      ...nestedStations.map(
        (station) => station.info.states
            .map(
              (state) => '''
T Function()? on${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}
''',
            )
            .join(','),
      ),
      'required T Function() orElse',
    ].join(', ');

    final body = [
      ...nestedStations.map(
        (station) => station.info.states
            .map(
              (state) => '''
if (currentState.${toStateMatcher(station.info.baseEnumName, state, station.info.baseEnumName == baseEnum.name)}) {
  return on${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}?.call() ?? orElse();
}
''',
            )
            .join('else '),
      )
    ].join('else ');
    buffer.writeln(
      '''
T map<T>({
  $arguments,
}) {
  $body
  return orElse();
}
''',
    );

    for (final station in nestedStations) {
      for (final state in station.info.states) {
        buffer.writeln(
          '''
  T? ${toMapMethodName('${station.info.baseEnumName}${toBeginningOfSentenceCase(state)}')}<T>(T Function() callback) {
    if (currentState.${toStateMatcher(station.info.baseEnumName, state, station.info.baseEnumName == baseEnum.name)}) {
      return callback();
    }
    return null;
  }
''',
        );
      }
    }
  }
}
