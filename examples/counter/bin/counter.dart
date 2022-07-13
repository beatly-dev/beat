import 'dart:io';

import 'counter.state.dart';

void main(List<String> arguments) {
  final counter = CounterStation(Counter.added, initialContext: 0);
  counter.attach(() {
    print("Counter is ${counter.currentContext}");
  });
  while (true) {
    counter.when(
      added: (p0) {
        p0.$add();
      },
      taken: (p0) {
        p0.$add();
      },
      or: () {},
    );

    sleep(Duration(milliseconds: 1000));
  }
}
