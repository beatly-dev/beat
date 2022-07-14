import 'package:beat/beat.dart';

import 'bulb.action.dart';

part 'bulb.state.beat.dart';

@Beat(event: BulbAction.destroy, to: Bulb.broken)
@BeatStation()
enum Bulb {
  @Beat(event: BulbAction.turnOn, to: Bulb.turnedOn)
  turnedOff,

  @Beat(event: BulbAction.turnOff, to: Bulb.turnedOff)
  turnedOn,

  broken,
}
