import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

@BeatStation(
  contextType: int,
)
@Beat(event: 'add', to: Counter.added, actions: [AssignAction(adder)])
@Beat(event: 'take', to: Counter.taken, actions: [AssignAction(taker)])
@Beat(event: 'reset', to: Counter.added, actions: [AssignAction(reset)])
enum Counter {
  added,

  taken,
}

int adder(Counter currentState, int prevContext, String eventName) {
  return prevContext + 1;
}

int taker(Counter currentState, int prevContext, String eventName) {
  return prevContext - 1;
}

int reset(Counter currentState, int prevContext, String eventName) {
  return 0;
}
