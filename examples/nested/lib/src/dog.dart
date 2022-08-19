import 'package:flutter_beat/flutter_beat.dart';

part 'dog.beat.dart';

@BeatStation()
enum Dog {
  @Beat(event: 'gotoWalk', to: onWalking)
  home,
  @Beat(event: 'goHome', to: home)
  @Substation(Tail)
  onWalking,
}

@BeatStation()
enum Tail {
  @Beat(event: 'wag', to: wagging)
  stopped,
  @Beat(event: 'stop', to: stopped)
  wagging,
}
