import 'dart:async';

import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

@BeatStation(
  contextType: int,
)
@Beat(event: 'reset', to: Counter.added)
enum Counter {
  @Beat(event: 'add', to: Counter.added, assign: adder)
  @Beat(event: 'take', to: Counter.taken, assign: taker)
  added,

  @Beat(event: 'add', to: Counter.added, assign: adder)
  @Beat(event: 'take', to: Counter.taken, assign: taker)
  taken,
}

int adder(Counter currentState, int prevContext, String eventName) {
  return prevContext + 1;
}

int taker(Counter currentState, int prevContext, String eventName) {
  return prevContext - 1;
}
