import 'dart:io';

import 'counter.state.dart';

void main(List<String> arguments) async {
  final counter = CounterBeatStation(
    CounterBeatState(context: 0, state: Counter.added),
  );

  counter.addListener(() {
    print("Counter is ${counter.currentState}");
  });

  counter.added.$add();
  sleep(Duration(milliseconds: 1000));
  counter.added.$add();
  sleep(Duration(milliseconds: 1000));
  counter.added.$add();
  sleep(Duration(milliseconds: 1000));
  counter.added.$take();
  sleep(Duration(milliseconds: 1000));
  counter.added.$take();
  sleep(Duration(milliseconds: 1000));
  counter.added.$take();
  sleep(Duration(milliseconds: 1000));
  counter.taken.$take();
  sleep(Duration(milliseconds: 1000));
  counter.taken.$take();
  sleep(Duration(milliseconds: 1000));
  counter.taken.$take();
  sleep(Duration(milliseconds: 1000));
  counter.taken.$add();
  sleep(Duration(milliseconds: 1000));
}
