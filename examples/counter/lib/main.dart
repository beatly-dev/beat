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
      firstState: Counter.loading,
      initialContext: CounterContext(),
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
            CounterConsumer(
              builder: (context, ref, _) {
                return Text(
                  '${ref.$$count ?? 0}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            CounterConsumer(
              builder: (contxt, ref, _) {
                return Text('Current Counter State: ${ref.currentState.state}');
              },
            ),
            CounterConsumer(
              builder: (contxt, ref, _) {
                if (ref.isAdded$) {
                  return const Text('Last transition: add');
                }
                return const SizedBox.shrink();
              },
            ),
            CounterConsumer(
              builder: (contxt, ref, _) {
                if (ref.isTaken$) {
                  return const Text('Last transition: take');
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: CounterConsumer(
        builder: (context, ref, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  ref.send.$takeOne();
                },
                tooltip: 'Decrement',
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: () {
                  ref.send.$addOne();
                },
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ],
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}