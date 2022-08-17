import 'dart:async';

import 'package:meta/meta.dart';

import '../../beat.dart';

abstract class BeatStationBase<State extends Enum, Context> {
  final _delayed = <Timer>{};

  BeatState get initialState;
  BeatState get currentState =>
      stateHistory.isEmpty ? initialState : stateHistory.last;
  List<BeatState> get stateHistory;
  final _stateStreamController = StreamController<BeatState>.broadcast();
  final _stateEnumStreamControler = StreamController<State>.broadcast();
  final _contextStreamController = StreamController<Context>.broadcast();

  Stream<BeatState> get stateStream => _stateStreamController.stream;
  Stream<State> get enumStream => _stateEnumStreamControler.stream;
  Stream<Context> get contextStream => _contextStreamController.stream;

  @protected
  @mustCallSuper
  setState(State state) {
    _stateStreamController.add(currentState);
    _stateEnumStreamControler.add(state);
  }

  @protected
  @mustCallSuper
  setContext(Context context) {
    _stateStreamController.add(currentState);
    _contextStreamController.add(context);
  }

  @protected
  triggerTransitions<Data>(
    Beat beat, [
    Data? data,
    Duration after = const Duration(milliseconds: 0),
  ]) {
    final nextState = beat.to;
    final eventName = beat.event;
    final actions = beat.actions;
    final conditions = beat.conditions;
    if (after.inMicroseconds > 0) {
      addDelayed(after, () {
        triggerTransitions(beat);
      });
    }
    final eventData = EventData(event: eventName, data: data);

    for (final condition in conditions) {
      if (!condition(currentState, eventData)) {
        return;
      }
    }

    for (final action in actions) {
      executeActions(action, eventName, eventData);
    }

    setState(nextState);
  }

  @protected
  executeActions(dynamic action, String eventName, EventData eventData) {
    exec() => action.execute(currentState, eventData);
    if (action is AssignActionBase) {
      setContext(exec());
    } else if (action is ChooseAction) {
      print("Conditional actions");
      final actions = exec();
      print("Execute conditional actions $actions");
      for (final action in actions) {
        print("Execute conditional actions $action");
        executeActions(action, eventName, eventData);
      }
    } else if (action is DefaultAction) {
      exec();
    } else if (action is Function(BeatState, EventData)) {
      action(currentState, eventData);
    } else if (action is Function(BeatState)) {
      action(currentState);
    } else if (action is Function()) {
      action();
    }
  }

  start();
  stop();

  @protected
  BeatStationBase? get child;

  @protected
  BeatStationBase? parent;

  @protected
  setParent(BeatStationBase p) {
    parent = p;
  }

  @protected
  BeatStationBase? ancestorOf(Type type) {
    if (currentState.state.runtimeType == type) {
      return this;
    }
    return parent?.ancestorOf(type);
  }

  @protected
  BeatStationBase? descendantOf(Type type) {
    /// 1. check current state has child
    if (currentState.state.runtimeType == type) {
      return this;
    }
    return child?.descendantOf(type);
  }

  BeatState? stateOf(Type type) {
    final state = ancestorOf(type)?.currentState;
    if (state != null) return state;
    return descendantOf(type)?.currentState;
  }

  @protected
  addDelayed(Duration duration, Function() callback) {
    _delayed.add(Timer(duration, callback));
  }

  @protected
  clearDelayed() {
    for (final timer in _delayed) {
      timer.cancel();
    }
    _delayed.clear();
  }
}
