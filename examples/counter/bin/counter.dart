import 'counter.state.dart';

void main(List<String> arguments) async {
  final counter = CounterBeatStation(
    CounterBeatState(context: 0, state: Counter.added),
  );

  counter.addListener(() {
    print("Counter is ${counter.currentState}");
  });

  while (true) {}
}
