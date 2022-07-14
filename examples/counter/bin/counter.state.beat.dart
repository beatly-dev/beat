// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter.state.dart';

// **************************************************************************
// StationGenerator
// **************************************************************************

class CounterStation {
  CounterStation(this.initialState, {required this.initialContext})
      : _currentState = initialState,
        _currentContext = initialContext {
    _addedBeats = AddedBeats(_setState, _setContext);
    _takenBeats = TakenBeats(_setState, _setContext);
  }

  late final AddedBeats _addedBeats;

  late final TakenBeats _takenBeats;

  int _currentContext;

  final int initialContext;

  Counter _currentState;

  final Counter initialState;

  final Map<String, Set<Function()>> _listeners = {};

  reset() {
    _currentState = initialState;
    _currentContext = initialContext;
    _notifyListeners();
  }

  attach(Function() callback) {
    _listeners['added'] ??= {};
    _listeners['added']!.add(callback);
    _listeners['taken'] ??= {};
    _listeners['taken']!.add(callback);
  }

  attachOnAdded(Function() callback) {
    _listeners['added'] ??= {};
    _listeners['added']!.add(callback);
  }

  attachOnTaken(Function() callback) {
    _listeners['taken'] ??= {};
    _listeners['taken']!.add(callback);
  }

  detach(Function() callback) {
    _listeners['added']?.remove(callback);
    _listeners['taken']?.remove(callback);
  }

  detachOnAdded(Function() callback) {
    _listeners['added']?.remove(callback);
  }

  detachOnTaken(Function() callback) {
    _listeners['taken']?.remove(callback);
  }

  T map<T>(
      {required T Function() or,
      T Function(AddedBeats)? added,
      T Function(TakenBeats)? taken}) {
    if (currentState.name == 'added' && added != null) {
      return added(_addedBeats);
    } else if (currentState.name == 'taken' && taken != null) {
      return taken(_takenBeats);
    }
    return or();
  }

  T mapAdded<T>(T Function(AddedBeats) callback) {
    return callback(_addedBeats);
  }

  T mapTaken<T>(T Function(TakenBeats) callback) {
    return callback(_takenBeats);
  }

  when(
      {required Function() or,
      Function(AddedBeats)? added,
      Function(TakenBeats)? taken}) {
    if (currentState.name == 'added' && added != null) {
      return added(_addedBeats);
    } else if (currentState.name == 'taken' && taken != null) {
      return taken(_takenBeats);
    }
    or();
  }

  whenAdded(Function(AddedBeats) callback) {
    callback(_addedBeats);
  }

  whenTaken(Function(TakenBeats) callback) {
    callback(_takenBeats);
  }

  int get currentContext {
    return _currentContext;
  }

  _setContext(int Function(int) modifier) {
    _currentContext = modifier(_currentContext);
  }

  Counter get currentState {
    return _currentState;
  }

  void _setState(Counter nextState) {
    _currentState = nextState;
    _notifyListeners();
  }

  void _notifyListeners() {
    for (final listener in _listeners[_currentState.name]?.toList() ?? []) {
      listener();
    }
  }
}

class AddedBeats {
  const AddedBeats(this._beat, this._setContext);

  final void Function(Counter nextState) _beat;

  final Function(int Function(int)) _setContext;

  $add() {
    _setContext(adder);
    _beat(Counter.added);
  }

  $take() {
    _beat(Counter.taken);
  }
}

class TakenBeats {
  const TakenBeats(this._beat, this._setContext);

  final void Function(Counter nextState) _beat;

  final Function(int Function(int)) _setContext;

  $add() {
    _setContext(adder);
    _beat(Counter.added);
  }

  $take() {
    _beat(Counter.taken);
  }
}
