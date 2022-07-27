import 'counter.state.dart';

void main(List<String> arguments) async {
  final counter = CounterBeatStation(
    CounterBeatState(context: 0, state: Counter.added),
  );

  counter.addListener(() {
    print("Counter is ${counter.currentState}");
  });

  counter.$add('hi');
  // to invoke services, use `Future.delay` rather than `sleep`.
  await Future.delayed(Duration(milliseconds: 1000));
  counter.$add('hi');
  await Future.delayed(Duration(milliseconds: 1000));
  counter.$add('hi');
  await Future.delayed(Duration(milliseconds: 1000));

  counter.$take('hi');
  await Future.delayed(Duration(milliseconds: 1000));

  counter.$take('hi');
  await Future.delayed(Duration(milliseconds: 1000));
  counter.$take('hi');
  await Future.delayed(Duration(milliseconds: 1000));

  counter.$take('hi');
  await Future.delayed(Duration(milliseconds: 1000));
  counter.$take('hi');
  await Future.delayed(Duration(milliseconds: 1000));
  counter.$take('hi');
  await Future.delayed(Duration(milliseconds: 1000));
  counter.$add('hi');
  await Future.delayed(Duration(milliseconds: 1000));
}
