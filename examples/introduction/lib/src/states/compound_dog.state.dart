import 'package:beat/beat.dart';

part 'compound_dog.state.beat.dart';

@BeatStation()
enum CuteDog {
  @Beat(event: 'leaveHome', to: onAWalk)
  waiting,

  @Beat(event: 'arriveHome', to: CuteDog.walkComplete)
  @Substation(WalkingDog)
  onAWalk,

  walkComplete,
}

@BeatStation()
enum WalkingDog {
  @Beat(event: 'stop', to: WalkingDog.stoppingToSniffGoodSmells)
  @Beat(event: 'speedUp', to: WalkingDog.running)
  @Substation(Tail)
  walking,

  @Beat(event: 'slowDown', to: WalkingDog.walking)
  @Beat(event: 'suddenStop', to: WalkingDog.stoppingToSniffGoodSmells)
  running,

  @Beat(event: 'speedUp', to: WalkingDog.walking)
  @Beat(event: 'suddenSpeedUp', to: WalkingDog.running)
  stoppingToSniffGoodSmells,
}

@BeatStation()
enum Tail {
  wagging,
}
