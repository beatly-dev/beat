import 'package:flutter_beat/flutter_beat.dart';
import 'package:nested/src/context.dart';

import 'tail.dart';

part 'dog.beat.dart';

@WithFlutter()
@BeatStation(contextType: MyContext)
enum Dog {
  @Beat(event: 'gotoWalk', to: onWalking)
  home,
  @Beat(event: 'goHome', to: home)
  @Substation(Tail)
  onWalking,
}
