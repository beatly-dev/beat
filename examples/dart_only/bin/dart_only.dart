import 'package:beat/beat.dart';

part 'dart_only.beat.dart';

@Station()
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
  @Substation(Tail)
  walking,

  @Beat(event: 'slowDown', to: Dog.walking)
  @Beat(event: 'goHome', to: Dog.home)
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
  @Substation(DogWithTail)
  @Final()
  wagging,
}

asdf() {}

@ParallelStation()
class DogWithTail {
  Dog? dog;
  Tail? tail;
  Tail? tail2;
}

void main(List<String> arguments) {
  print('Hello world!');
}
