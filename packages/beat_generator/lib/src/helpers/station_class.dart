import 'package:analyzer/dart/element/element.dart';

import '../models/beat_config.dart';
import '../models/compound_config.dart';
import '../models/invoke_config.dart';
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
  final String contextType;
  final List<BeatConfig> commonBeats;
  late final String baseName;
  late final String beatStationClassName;
  late final List<String> enumFields;
  late final String beatStateClassName;
  final Map<String, List<BeatConfig>> beats;
  final Map<String, List<InvokeConfig>> invokes;
  final List<CompoundConfig> compounds;

  final buffer = StringBuffer();

  BeatStationBuilder({
    required this.baseEnum,
    required this.contextType,
    required this.commonBeats,
    required this.beats,
    required this.invokes,
    required this.compounds,
  }) {
    baseName = baseEnum.name;
    beatStationClassName = toBeatStationClassName(baseName);
    beatStateClassName = toBeatStateClassName(baseName);
    enumFields = baseEnum.fields
        .where((element) => element.isEnumConstant)
        .map((field) => field.name)
        .toList();
  }

  String build() {
    _createConstructor();
    _createFields();
    _createBeatSender();
    _createTransitionFields();
    _createCompoundGetter();
    _createExecMethods();
    _createMapMethods();
    _createCurrentStateCheckerGetter();
    _createSetState();
    _createInvokeServices();
    _createSetContext();
    _createCommonBeatTransitions();
    _createListenersMethods();
    _createNotifyListenersMethod();
    _createReset();
    return createClass(
      '$beatStationClassName extends BaseBeatStation',
      buffer.toString(),
    );
  }

  void _createCompoundGetter() {
    for (final compound in compounds) {
      final className = toBeatStationClassName(compound.childBase);
      final fieldName = toCompoundFieldName(compound.childBase);
      buffer.writeln(
        '''
late final $className $fieldName;
''',
      );
    }
  }

  void _createBeatSender() {
    final arguments = [
      'this',
      ...compounds.map((compound) => toCompoundFieldName(compound.childBase)),
    ].join(', ');
    buffer.writeln(
      '''
${toBeatSenderClassName(baseName)} get send => ${toBeatSenderClassName(baseName)}()..${toBeatSenderInitializerMethodName(baseName)}($arguments);
''',
    );
  }

  void _createInvokeServices() {
    final body =
        invokes.keys.where((state) => invokes[state]!.isNotEmpty).map((state) {
      final config = invokes[state]![0];
      final varName = toInvokeVariableName(config);

      /// TODO: transition on done/error
      return '''
if (currentState.state == ${config.stateName}.${config.on}) {
  for (final invoke in $varName.invokes) {
    if (invoke is InvokeFuture) {
      (() async {
        final onDone = invoke.onDone;
        final onError = invoke.onError;
        try {
          await invoke.invokeWith(currentState.state, currentState.context, '');
          for (final action in onDone.actions) {
            ${ActionExecutorBuilder(
        actionName: 'action',
        baseName: baseName,
        contextType: contextType,
        eventData: "EventData(event: 'invoke', data: null)",
        isStation: true,
      ).build()}
          }
          if (onDone.to is $baseName) {
            _setState(onDone.to);
          }
        } catch (_) {
          for (final action in onError.actions) {
            ${ActionExecutorBuilder(
        actionName: 'action',
        baseName: baseName,
        contextType: contextType,
        eventData: "EventData(event: 'invoke', data: null)",
        isStation: true,
      ).build()}
          }
          if (onError.to is $baseName) {
            _setState(onError.to);
          }
        }
      })();
    }
  }
}
''';
    }).join('else ');

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
    _history.add(_initialState);
  }

  void clearState() {
    _history.clear();
    resetState();
  }
''',
    );
  }

  void _createCommonBeatTransitions() {
    for (final config in commonBeats) {
      buffer.writeln(
        '''
void _exec${toBeginningOfSentenceCase(config.event)}Actions(EventData eventData) {
  for (final action in ${toBeatActionVariableName(config.from, config.event, config.to)}.actions) {
    ${ActionExecutorBuilder(
          actionName: 'action',
          baseName: baseName,
          contextType: contextType,
          eventData: 'eventData',
          isStation: true,
        ).build()}
  }
}
''',
      );
      buffer.writeln(
        '''
void \$${config.event}<Data>([Data? data]) {
  _exec${toBeginningOfSentenceCase(config.event)}Actions(EventData(
    event: '${config.event}',
    data: data,
  ));
  _setState($baseName.${config.to});
}
''',
      );
    }
  }

  void _createTransitionFields() {
    for (final state in enumFields) {
      final beatConfigs = beats[state] ?? [];
      buffer.writeln(
        '''${toBeatTransitionBaseClassName(baseName, state)} get ${toDartFieldCase(state)} {
          if (currentState.state == $baseName.$state) {
            return ${toBeatTransitionRealClassName(baseName, state)}(${beatConfigs.isEmpty ? '' : 'this'});
          }
          return const ${toBeatTransitionDummyClassName(baseName, state)}();
        }''',
      );
    }
  }

  void _createSetState() {
    buffer.writeln(
      '''
void _setState($baseName state) {
  final nextState = $beatStateClassName(state: state, context: currentState.context);
  _history.add(nextState);
  _notifyListeners();
  _invokeServices();
}
''',
    );
  }

  void _createSetContext() {
    final contextType =
        isNullContextType(this.contextType) ? 'dynamic' : this.contextType;
    buffer.writeln(
      '''
void _setContext($contextType context) {
  final nextState = $beatStateClassName(state: currentState.state, context: context);
  _history.add(nextState);
  _notifyListeners();
}
''',
    );
  }

  void _createConstructor() {
    final enumField = baseEnum.fields.where(
      (field) => field.isEnumConstant,
    );
    final firstFieldName = enumField.isNotEmpty ? enumField.first.name : '';

    final beatStateName = toBeatStateClassName(baseName);
    buffer.writeln(
      '  $beatStationClassName([this._initialState = const $beatStateName(state: $baseName.$firstFieldName)]) {',
    );
    for (final compound in compounds) {
      final enumName = compound.childBase;
      final className = toBeatStationClassName(enumName);
      final fieldName = toCompoundFieldName(enumName);
      buffer.writeln(
        '''
$fieldName = $className();
''',
      );
    }
    buffer.writeln('    _history.add(_initialState);');
    buffer.writeln('  }');
  }

  void _createFields() {
    buffer.writeln(
      '''
  final List<$beatStateClassName> _history = [];
  List<$beatStateClassName> get history => [..._history];
  late final $beatStateClassName _initialState;
  $beatStateClassName get currentState => history.isEmpty
      ? _initialState
      : history.last;
  $beatStateClassName get initialState => _initialState;
''',
    );
    buffer.writeln(
      '''
final _listeners = <Function>[];
''',
    );
    for (final name in enumFields) {
      buffer.writeln(
        '''
final ${toListenerFieldName(name)} = <Function>[];
''',
      );
    }
  }

  void _createNotifyListenersMethod() {
    buffer.writeln(
      '''
  void _notifyListeners() {
    _listeners.forEach((listener) => listener());
    ''',
    );

    buffer.writeln(
      enumFields
          .map(
            (name) => '''
if (currentState.state == $baseName.$name) {
    ${toListenerFieldName(name)}.forEach((listener) => listener());
}
    ''',
          )
          .join('else '),
    );
    buffer.writeln(
      '''
  }
''',
    );
  }

  void _createListenersMethods() {
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
    for (final name in enumFields) {
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

  void _createExecMethods() {
    final arguments = [
      ...enumFields.map(
        (name) => '''
Function()? on${toBeginningOfSentenceCase(name)}
''',
      ),
      'required Function() orElse',
    ].join(', ');

    final body = [
      ...enumFields.map(
        (name) => '''
if (currentState.state == $baseName.$name) {
  return on${toBeginningOfSentenceCase(name)}?.call() ?? orElse();
}
''',
      )
    ].join('else ');
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
    for (final name in enumFields) {
      buffer.writeln(
        '''
  void ${toExecMethodName(name)}(Function() callback) {
    if (currentState.state == $baseName.$name) {
      callback();
    }
  }
''',
      );
    }
  }

  void _createMapMethods() {
    final arguments = [
      ...enumFields.map(
        (name) => '''
T Function()? on${toBeginningOfSentenceCase(name)}
''',
      ),
      'required T Function() orElse',
    ].join(', ');

    final body = [
      ...enumFields.map(
        (name) => '''
if (currentState.state == $baseName.$name) {
  return on${toBeginningOfSentenceCase(name)}?.call() ?? orElse();
}
''',
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

    for (final name in enumFields) {
      buffer.writeln(
        '''
  T? ${toMapMethodName(name)}<T>(T Function() callback) {
    if (currentState.state == $baseName.$name) {
      return callback();
    }
    return null;
  }
''',
      );
    }
  }

  void _createCurrentStateCheckerGetter() {
    for (final name in enumFields) {
      buffer.writeln(
        '''
  bool get ${toCurrentStateCheckerGetterName(name)} =>
      currentState.state == $baseName.$name;
''',
      );
    }
  }
}
