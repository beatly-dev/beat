import 'package:beat/beat.dart';

part 'dog_in_a_house.state.beat.dart';

@BeatStation()
enum DogInAHouse {
  @Beat(event: 'wakesUp', to: DogInAHouse.awake)
  asleep,

  @Beat(event: 'fallsAsleep', to: DogInAHouse.asleep)
  awake,
}
