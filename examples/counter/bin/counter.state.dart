import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

@BeatStation(
  contextType: int,
)
@Beat(event: 'add', to: Counter.added, actions: [AssignAction(adder), save])
@Beat(event: 'take', to: Counter.taken, actions: [AssignAction(taker), save])
@Beat(event: 'reset', to: Counter.added, actions: [AssignAction(reset), save])
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

save(state, int context, event) async {
  print("Saving...");
}
