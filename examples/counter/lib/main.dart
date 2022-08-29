import 'package:flutter/material.dart';

import 'src/counter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CounterProvider(
      initialContext: 0,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            RepaintBoundary(
              child: CounterConsumer(
                builder: (context, ref) {
                  final counter = ref.select(
                    (machine) {
                      final counterState = machine.stateOf<CounterState>();
                      return counterState?.context ?? 0;
                    },
                  );
                  return Text(
                    '$counter',
                    style: Theme.of(context).textTheme.headline4,
                  );
                },
              ),
            ),
            RepaintBoundary(
              child: CounterConsumer(
                builder: (context, ref) {
                  final count =
                      ref.machine.stateOf<CounterState>()?.context ?? 0;
                  return Text(
                    'machine level only counter: $count',
                  );
                },
              ),
            ),
            RepaintBoundary(
              child: CounterConsumer(
                builder: (context, ref) {
                  final count = ref.select(
                    (machine) {
                      final count =
                          machine.stateOf<CounterState>()?.context ?? 0;
                      return (count ~/ 2) * 2;
                    },
                  );
                  return Text(
                    'Even number counter: $count',
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CounterConsumer(
        builder: (context, ref) {
          return RepaintBoundary(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    ref.read((machine) => machine.send).$takeOne();
                  },
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    ref.read((machine) => machine.send).$addOne();
                  },
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
