import 'package:beat/beat.dart';

part 'walking_dog.state.beat.dart';

@BeatStation()
enum WalkingDog {
  @Beat(event: 'leaveHome', to: WalkingDog.onAWalk)
  waiting,

  @Beat(event: 'arriveHome', to: WalkingDog.walkComplete)
  onAWalk,

  walkComplete,
}
