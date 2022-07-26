import 'dart:io';

import 'counter.state.dart';

void main(List<String> arguments) async {
  final counter = CounterBeatStation(
    CounterBeatState(context: 0, state: Counter.added),
  );

  counter.addListener(() {
    print("Counter is ${counter.currentState}");
  });

  counter.$add();
  sleep(Duration(milliseconds: 1000));
  counter.$add();
  sleep(Duration(milliseconds: 1000));
  counter.$add();
  sleep(Duration(milliseconds: 1000));
  counter.$take();
  sleep(Duration(milliseconds: 1000));
  counter.$take();
  sleep(Duration(milliseconds: 1000));
  counter.$take();
  sleep(Duration(milliseconds: 1000));
  counter.$take();
  sleep(Duration(milliseconds: 1000));
  counter.$take();
  sleep(Duration(milliseconds: 1000));
  counter.$take();
  sleep(Duration(milliseconds: 1000));
  counter.$add();
  sleep(Duration(milliseconds: 1000));
}
