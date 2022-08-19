import 'package:flutter_beat/flutter_beat.dart';

import 'tail.dart';

part 'dog.beat.dart';

@WithFlutter()
@BeatStation()
enum Dog {
  @Beat(event: 'gotoWalk', to: onWalking)
  home,
  @Beat(event: 'goHome', to: home)
  @Substation(Tail)
  onWalking,
}
