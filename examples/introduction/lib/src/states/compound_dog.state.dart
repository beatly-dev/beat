import 'package:beat/beat.dart';

part 'compound_dog.state.beat.dart';

@BeatStation()
enum CompoundDog {
  @Beat(event: 'leaveHome', to: CompoundDog.onAWalk)
  waiting,

  @Beat(event: 'arriveHome', to: CompoundDog.walkComplete)
  @Compound(OnWalkingDog)
  onAWalk,

  walkComplete,
}

@BeatStation()
enum OnWalkingDog {
  @Beat(event: 'stop', to: OnWalkingDog.stoppingToSniffGoodSmells)
  @Beat(event: 'speedUp', to: OnWalkingDog.running)
  walking,

  @Beat(event: 'slowDown', to: OnWalkingDog.walking)
  @Beat(event: 'suddenStop', to: OnWalkingDog.stoppingToSniffGoodSmells)
  running,

  @Beat(event: 'speedUp', to: OnWalkingDog.walking)
  @Beat(event: 'suddenSpeedUp', to: OnWalkingDog.running)
  stoppingToSniffGoodSmells,
}
