import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

const addBeat =
    Beat(event: 'add', to: Counter.added, actions: [AssignAction(adder)]);

@BeatStation(contextType: int)
@Beat(event: 'take', to: Counter.taken, actions: [AssignAction(taker)])
@Beat(
    event: 'reset', to: Counter.added, actions: [Reset(), AssignAction(reset)])
@addBeat
enum Counter {
  @Beat(event: 'test', to: Counter.added)
  @Beat(event: 'reset', to: Counter.added, actions: [AssignAction(reset)])
  @Invokes([
    InvokeFuture(save),
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

class Reset extends AssignActionBase {
  const Reset();
  @override
  Function(BeatState currentState, EventData event) get action => (_, __) {
        print("Reseter");
        return 0;
      };
}

saveError(
  _,
  __,
) async {
  throw UnimplementedError();
}

logError() {
  print("Error on Save!");
}

int adder(BeatState state, _) {
  return state.context + 1;
}

int taker(BeatState state, EventData event) {
  print("EventData: ${event.event}, ${event.data}");
  return state.context - 1;
}

int reset(BeatState state, EventData event) {
  print("EventData: ${event.event}, ${event.data}");
  return 0;
}

save(_, String event) async {
  print("Saving... $event ");
}

done() {
  print("Saved!!");
}
