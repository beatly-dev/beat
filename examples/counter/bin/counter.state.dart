import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

@BeatStation(
  contextType: int,
)
@Beat(event: 'reset', to: Counter.added)
enum Counter {
  @Beat(event: 'add', to: Counter.added, actions: [AssignAction(adder)])
  @Beat(event: 'take', to: Counter.taken, actions: [AssignAction(adder)])
  added,

  @Beat(event: 'add', to: Counter.added, actions: [adder])
  @Beat(event: 'take', to: Counter.taken, actions: [taker])
  taken,
}

int adder(Counter currentState, int prevContext, String eventName) {
  return prevContext + 1;
}

int taker(Counter currentState, int prevContext, String eventName) {
  return prevContext - 1;
}
