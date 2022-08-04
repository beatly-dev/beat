import 'package:beat/beat.dart';

part 'compound_dog.state.beat.dart';

@BeatStation()
enum CuteDog {
  @Beat(event: 'leaveHome', to: onAWalk)
  waiting,

  @Beat(event: 'arriveHome', to: CuteDog.walkComplete)
  @Substation(CuteWalkingDog)
  onAWalk,

  walkComplete,
}

@BeatStation()
enum CuteWalkingDog {
  @Beat(event: 'stop', to: CuteWalkingDog.stoppingToSniffGoodSmells)
  @Beat(event: 'speedUp', to: CuteWalkingDog.running)
  @Substation(CuteTail)
  walking,

  @Beat(event: 'slowDown', to: CuteWalkingDog.walking)
  @Beat(event: 'suddenStop', to: CuteWalkingDog.stoppingToSniffGoodSmells)
  running,

  @Beat(event: 'speedUp', to: CuteWalkingDog.walking)
  @Beat(event: 'suddenSpeedUp', to: CuteWalkingDog.running)
  stoppingToSniffGoodSmells,
}

@BeatStation()
enum CuteTail {
  wagging,
}
