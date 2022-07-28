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
  @Invokes([
    InvokeFuture(save,
        onDone: AfterInvoke(to: Counter.added, actions: [AssignAction(adder)]))
  ])
  added,

  @Beat(event: 'test', to: Counter.added)
  @Invokes([
    InvokeFuture(saveError,
        onError: AfterInvoke(to: Counter.error, actions: [logError]))
  ])
  taken,
  error,
}

saveError(_, __, ___) async {
  throw UnimplementedError();
}

logError() {
  print("Error on Save!");
}

int adder(Counter currentState, int prevContext, EventData event) {
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
