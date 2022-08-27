import 'package:beat/beat.dart';

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
  sleeping,
}

@Station(contextType: String)
@OnEntry([asdf])
@OnExit([])
enum Tail {
  @OnExit([])
  @OnEntry([asdf])
  stopped,
  @OnExit([])
  @OnEntry([asdf])
  @Services()
  @Final()
  wagging,
}

asdf() {}

@ParallelStation()
class DogWithTail {
  static const dog = Dog.home;
  static const taile = Tail.stopped;
}

void main(List<String> arguments) {
  print('Hello world!');
}
