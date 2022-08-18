import 'package:flutter_beat/flutter_beat.dart';
import 'package:flutter/material.dart';

part 'counter.beat.dart';

@WithFlutter()
@BeatStation(contextType: CounterContext)
@addOneBeat
@takeOneBeat
enum Counter {
  @initializer
  loading,
  idle,
  added,
  taken,
}

class CounterContext {
  final int count;
  final Dummy dummy = const Dummy();

  CounterContext([this.count = 0]);
}

class Dummy {
  const Dummy();
}

const initializer = Invokes([
  InvokeFuture(
    initializeStation,
    onDone: AfterInvoke(
      to: Counter.idle,
      actions: [AssignAction(assignValue)],
    ),
  )
]);

Future<CounterContext> initializeStation(_, __) async {
  return CounterContext();
}

CounterContext assignValue(_, EventData event) {
  return event.data;
}

const addOneBeat =
    Beat(event: 'addOne', to: Counter.added, actions: [AssignAction(addOne)]);
const takeOneBeat =
    Beat(event: 'takeOne', to: Counter.taken, actions: [AssignAction(takeOne)]);

CounterContext addOne(BeatState state, _) {
  return CounterContext(state.context.count + 1);
}

CounterContext takeOne(BeatState state, _) {
  return CounterContext(state.context.count - 1);
}
