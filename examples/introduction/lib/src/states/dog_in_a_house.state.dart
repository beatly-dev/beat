import 'package:beat/beat.dart';

part 'dog_in_a_house.state.beat.dart';

@BeatStation()
@Beat(event: 'leaveHome', to: DogInAHouse.awake)
enum DogInAHouse {
  @Beat(
    event: 'wakesUp',
    to: awake,
    conditions: [],
    actions: [BowWow2, AssignAction(assign)],
  )
  asleep,

  @Beat(event: 'fallsAsleep', to: asleep)
  @Substation(Hi)
  @Invokes()
  awake,
}

enum Hi { ho }

BowWow2() {
  if (DogInAHouse is Enum) {
    print('it is an enum');
  }
}

assign(_, __, ___) {
  return 1;
}
