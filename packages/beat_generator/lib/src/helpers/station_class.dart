import 'package:analyzer/dart/element/element.dart';

import '../models/beat_config.dart';
import '../utils/context.dart';
import '../utils/create_class.dart';
import '../utils/string.dart';

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

  final buffer = StringBuffer();

  BeatStationBuilder({
    required this.baseEnum,
    required this.contextType,
    required this.commonBeats,
    required this.beats,
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
    _createTransitionFields();
    _createExecMethods();
    _createMapMethods();
    _createCurrentStateCheckerGetter();
    _createSetState();
    _createSetContext();
    _createCommonBeatTransitions();
    _createListenersMethods();
    _createNotifyListenersMethod();
    _createReset();
    return createClass(
      beatStationClassName,
      buffer.toString(),
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
    exec() => 
      action.execute(currentState.state, currentState.context, eventData);
    if (action is AssignAction) {
      _setContext(exec());
    } else if (action is DefaultAction) {
      exec();
    } else if (action is Function($baseName, $contextType, EventData)) {
      action(currentState.state, currentState.context, eventData);
    } else if (action is Function($baseName, $contextType)) {
      action(currentState.state, currentState.context);
    } else if (action is Function($baseName)) {
      action(currentState.state);
    } else if (action is Function()) {
      action();
    }
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
        '''${toBeatTransitionBaseClassName(state)} get ${toDartFieldCase(state)} {
          if (currentState.state == $baseName.$state) {
            return ${toBeatTransitionRealClassName(state)}(${beatConfigs.isEmpty ? '' : 'this'});
          }
          return ${toBeatTransitionDummyClassName(state)}();
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
    buffer.writeln(
      '  $beatStationClassName(this._initialState) {',
    );
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
