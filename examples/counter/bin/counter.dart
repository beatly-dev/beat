import 'counter.state.dart';

void main(List<String> arguments) async {
  final counter = CounterStation(Counter.added, initialContext: 0);
  counter.attach(() {
    print("Counter is ${counter.currentContext}");
  });
  while (true) {
    counter.when(
      added: (p0) async {
        print("Take one");
        await p0.$take();
      },
      taken: (p0) async {
        print("Add one");
        await p0.$add();
      },
      or: () {},
    );

    // should have async gap to run assigner properly
    await Future.delayed(Duration(milliseconds: 1000));
    // sleep(Duration(milliseconds: 1000));
  }
}
