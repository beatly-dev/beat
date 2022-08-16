import 'counter.state.dart';

void main(List<String> arguments) async {
  final counter = CounterBeatStation(
    firstState: Counter.added,
    initialContext: 0,
  );

  counter.addListener(() {
    print("Counter is ${counter.currentState.context}");
  });

  counter.$add();
  // to invoke services, use `Future.delay` rather than `sleep`.
  counter.$add();
  counter.$add();

  counter.$take();

  counter.$take();
  counter.$take();

  counter.$take();
  counter.$take();
  counter.$take();
  counter.$add();
  counter.$reset();
}
