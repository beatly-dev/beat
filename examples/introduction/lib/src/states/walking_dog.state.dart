import 'package:beat/beat.dart';

part 'walking_dog.state.beat.dart';

@BeatStation(contextType: int)
@Beat(event: 'complete', to: WalkingDog.walkComplete)
enum WalkingDog {
  @Beat(event: ' leaveHome ', to: onAWalk)
  waiting,

  @Beat(event: r'arr$$$@@#!ive    Home', to: WalkingDog.walkComplete)
  @Invokes([])
  onAWalk,

  walkComplete,
}
