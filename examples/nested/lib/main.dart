import 'package:flutter/material.dart';
import 'package:nested/src/dog.dart';
import 'package:nested/src/tail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DogProvider(
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
            DogConsumer(
              builder: (context, ref) {
                final isWalking =
                    ref.select((station) => station.currentState.isOnWalking$);
                return Text("Bow wow walking: $isWalking");
              },
            ),
            const TailListener(),
            TailConsumer(
              builder: (context, ref) {
                final isWagging = ref.station.currentState.isWagging$;
                return Text(isWagging ? "Wagging" : "Stopped");
              },
              placeHolder: const Text("Tail not started"),
            )
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TailConsumer(
              builder: (context, ref) {
                return FloatingActionButton(
                  onPressed: () {
                    ref.readStation.send.$wag();
                  },
                  tooltip: 'Increment',
                  child: const Icon(Icons.motorcycle),
                );
              },
            ),
            TailConsumer(
              builder: (context, ref) {
                return FloatingActionButton(
                  onPressed: () {
                    ref.readStation.send.$stop();
                  },
                  tooltip: 'Increment',
                  child: const Icon(Icons.stop),
                );
              },
            ),
            DogConsumer(
              builder: (context, ref) {
                return FloatingActionButton(
                  onPressed: () {
                    ref.readStation.send.$goHome();
                  },
                  tooltip: 'Increment',
                  child: const Icon(Icons.home),
                );
              },
            ),
            DogConsumer(
              builder: (context, ref) {
                return FloatingActionButton(
                  onPressed: () {
                    ref.readStation.send.$gotoWalk();
                  },
                  tooltip: 'Increment',
                  child: const Icon(Icons.directions_walk),
                );
              },
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TailListener extends StatefulTailConsumerWidget {
  const TailListener({Key? key}) : super(key: key);

  @override
  TailConsumerWidgetState<StatefulTailConsumerWidget> createState() =>
      _TailState();
}

class _TailState extends TailConsumerWidgetState<TailListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.readStation.removeListener(handleDog);
    ref.readStation.addListener(handleDog);
  }

  handleDog() {
    final state = ref.readStation.currentState.state;
    print("Tail is $state");
  }

  @override
  Widget build(BuildContext context) {
    return const Text("I am a tail listener");
  }
}
