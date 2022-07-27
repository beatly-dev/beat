import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

@BeatStation(
  contextType: int,
)
@Beat(
    event: 'add', to: Counter.added, actions: [AssignAction(adder), save, done])
@Beat(
    event: 'take',
    to: Counter.taken,
    actions: [AssignAction(taker), save, done])
@Beat(
    event: 'reset',
    to: Counter.added,
    actions: [AssignAction(reset), save, done])
enum Counter {
  @Beat(event: 'test', to: Counter.added)
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

save(state, int context, event) async {
  print("Saving... ${event.event} ${event.data}");
}

done() {
  print("Saved!!");
}
