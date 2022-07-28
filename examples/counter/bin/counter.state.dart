import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

const addBeat = Beat(event: 'add', to: 'added', actions: [AssignAction(adder)]);

@BeatStation(contextType: int)
@Beat(event: 'take', to: Counter.taken, actions: [AssignAction(taker)])
@Beat(event: 'reset', to: Counter.added, actions: [AssignAction(reset)])
@addBeat
enum Counter {
  @Beat(event: 'test', to: Counter.added)
  @Beat(event: 'reset', to: Counter.added, actions: [AssignAction(reset)])
  @Invokes([InvokeFuture(save)])
  added,

  @Beat(event: 'test', to: Counter.added)
  @Invokes([InvokeFuture(save)])
  taken,
}

int adder(Counter currentState, int prevContext, EventData event) {
  print("EventData: ${event.event}, ${event.data}");
  return prevContext + 1;
}

int taker(Counter currentState, int prevContext, EventData event) {
  print("EventData: ${event.event}, ${event.data}");
  return prevContext - 1;
}

int reset(Counter currentState, int prevContext, EventData event) {
  print("EventData: ${event.event}, ${event.data}");
  return 0;
}

save(Counter state, int context, String event) async {
  print("Saving... $event ");
}

done() {
  print("Saved!!");
}
