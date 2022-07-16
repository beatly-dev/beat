import 'dart:io';

import 'counter.state.dart';

void main(List<String> arguments) async {
  final counter = CounterStation(Counter.added, initialContext: 0);
  counter.attach(() {
    print("Counter is ${counter.currentContext}");
  });
  while (true) {
    print('next events: ${counter.nextEvents}');
    counter.when(
      added: (p0) async {
        print("Take one");
        final next = p0.$take();
        if (next is Future) {
          print("Next is future");
        }
        print("result $next");
      },
      taken: (p0) async {
        print("Add one");
        final next = p0.$add();
        if (next is Future) {
          print("Next is future");
        }
        print("result $next");
      },
      or: () {},
    );

    // should have async gap to run assigner properly
    // await Future.delayed(Duration(milliseconds: 1000));
    sleep(Duration(milliseconds: 500));
  }
}
