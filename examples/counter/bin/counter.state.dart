import 'package:beat/beat.dart';

part 'counter.state.beat.dart';

typedef Counting = int;

@BeatStation<int>()
enum Counter {
  @Beat(event: 'add', to: Counter.added, assign: adder)
  @Beat(event: 'take', to: Counter.taken)
  added,

  @Beat(event: 'add', to: Counter.added, assign: adder)
  @Beat(event: 'take', to: Counter.taken)
  taken,
}

Counting adder(Counting prev) {
  return prev + 1;
}

Counting taker(Counting prev) {
  return prev - 1;
}
