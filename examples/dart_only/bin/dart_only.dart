import 'package:beat/beat.dart';

part 'dart_only.beat.dart';

@Station(id: 'Dog')
@Beat(event: 'sleep', to: Dog.sleeping)
enum Dog {
  @Beat(event: 'walk', to: Dog.walking)
  @Beat(event: 'run', to: Dog.running)
  @EventlessBeat(
      to: Dog.walking,
      after: Duration(microseconds: 100, milliseconds: 1000, seconds: 1))
  @Substation(Tail)
  home,

  @Beat(event: 'speedUp', to: Dog.running)
  @Beat(event: 'goHome', to: Dog.home)
  @Beat(event: 'run', to: Dog.running)
  @Substation(Tail)
  walking,

  @Beat(event: 'slowDown', to: Dog.walking)
  @Beat(event: 'goHome', to: Dog.home)
  @Beat(event: 'walk', to: Dog.walking)
  @Substation(Tail)
  running,

  @Final()
  @Services()
  @Services()
  @Services()
  sleeping,
}

@Station(contextType: String)
@OnEntry([asdf])
@OnExit([])
enum Tail {
  @OnExit([])
  @OnEntry([asdf])
  @Beat(event: 'wag', to: Tail.wagging)
  stopped,
  @OnExit([])
  @OnEntry([asdf])
  @Services()
  @Services()
  @Services()
  @Beat(event: 'stop', to: Tail.stopped)
  @Final()
  wagging,
}

asdf() {}

@ParallelStation(id: 'jiji')
class DogWithTail {
  /// Field type defines what station to use
  static const Dog dog = Dog.home;

  /// field name is an ID for the station
  static const Tail tail = Tail.stopped;

  /// Field value is a beginning state
  static const Tail tail2 = Tail.wagging;
}

void main(List<String> arguments) {
  final machine = DogMachine();
  machine.send.$wag();
  print('changed: ${machine.changed} - ${machine.currentState}');
  machine.send.$walk();
  print('changed: ${machine.changed} - ${machine.currentState}');
  machine.send.$run();
  print('changed: ${machine.changed} - ${machine.currentState}');
  machine.send.$wag();
  print('changed: ${machine.changed} - ${machine.currentState}');

  final pMachine = DogWithTailMachine();
  print(pMachine.currentState);
  pMachine.send.$run();
  print(pMachine.currentState);
}
