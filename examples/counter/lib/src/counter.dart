import 'package:flutter_beat/flutter_beat.dart';

part 'counter.beat.dart';

@Station(contextType: int, withFlutter: true)
@addOneBeat
@takeOneBeat
enum Counter {
  @initializer
  loading,
  idle,
  added,
  taken,
}

class Dummy {
  const Dummy();
}

const initializer = Services([]);

Future<int> initializeStation(_, __) async {
  return 0;
}

int assignValue(_, EventData event) {
  return event.data;
}

const addOneBeat =
    Beat(event: 'addOne', to: Counter.added, actions: [Assign(addOne)]);
const takeOneBeat =
    Beat(event: 'takeOne', to: Counter.taken, actions: [Assign(takeOne)]);

int addOne(BeatState state, _) {
  return (state.context ?? 0) + 1;
}

int takeOne(BeatState state, _) {
  return (state.context ?? 0) - 1;
}
