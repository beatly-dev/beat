import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

@BeatStation(
  contextType: int,
)
enum Counter {
  @Beat(event: 'add', to: Counter.added, assign: adder)
  @Beat(event: 'take', to: Counter.taken)
  added,

  @Beat(event: 'add', to: Counter.added, assign: adder)
  @Beat(event: 'take', to: Counter.taken)
  taken,
}

int adder(int prev) {
  return prev + 1;
}

int taker(int prev) {
  return prev - 1;
}
