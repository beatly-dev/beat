import 'package:beat/beat.dart';

import 'bulb.action.dart';

part 'bulb.state.beat.dart';

@BeatStation()
enum Bulb {
  @Beat(event: BulbAction.turnOn, to: Bulb.turnedOn)
  @Beat(event: BulbAction.destroy, to: Bulb.broken)
  turnedOff,

  @Beat(event: BulbAction.turnOff, to: Bulb.turnedOff)
  @Beat(event: BulbAction.destroy, to: Bulb.broken)
  turnedOn,

  broken,
}
