import 'dart:async';

import 'package:meta/meta.dart';

import '../../beat.dart';

abstract class BeatStationBase {
  final _delayed = <Timer>{};

  BeatState get currentState;

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
