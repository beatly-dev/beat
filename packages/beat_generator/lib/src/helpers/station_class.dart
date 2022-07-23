import 'package:analyzer/dart/element/element.dart';

import '../utils/context.dart';
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
  late final String baseName;
  late final String beatStationClassName;
  late final List<String> enumFields;
  late final String beatStateClassName;

  final buffer = StringBuffer();

  BeatStationBuilder({required this.baseEnum, required this.contextType}) {
    baseName = baseEnum.name;
    beatStationClassName = toBeatStationClassName(baseName);
    beatStateClassName = toBeatStateClassName(baseName);
    enumFields = baseEnum.fields
        .where((element) => element.isEnumConstant)
        .map((field) => field.name)
        .toList();
  }

  String build() {
    buffer.writeln('class $beatStationClassName {');
    _createConstructor();
    _createFields();
    _createStateFields();
    _createExecMethods();
    _createMapMethods();
    _createCurrentStateCheckerGetter();
    _createSetState();
    _createSetContext();
    _createListenersMethods();
    _createNotifyListenersMethod();
    buffer.writeln('}');
    return buffer.toString();
  }

  void _createStateFields() {
    for (final state in enumFields) {
      buffer.writeln(
        '''late final ${toBeatTransitionClassName(state)} ${toDartFieldCase(state)};''',
      );
    }
  }

  void _createSetState() {
    buffer.writeln(
      '''
void _setState($baseName state) {
  final nextState = $beatStateClassName(state: state, context: currentState.context);
  history.add(nextState);
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
  history.add(nextState);
  _notifyListeners();
}
''',
    );
  }

  void _createConstructor() {
    buffer.writeln(
      '  $beatStationClassName(this._initialState) {',
    );
    buffer.writeln('    history.add(_initialState);');
    for (final state in enumFields) {
      buffer.writeln(
        '''${toDartFieldCase(state)} = ${toBeatTransitionClassName(state)}(this);''',
      );
    }
    buffer.writeln('  }');
  }

  void _createFields() {
    buffer.writeln(
      '''
  final List<$beatStateClassName> history = [];
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
