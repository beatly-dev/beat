import 'package:flutter_beat/flutter_beat.dart';

part 'tail.beat.dart';

@WithFlutter()
@BeatStation()
enum Tail {
  @Beat(event: 'wag', to: wagging)
  stopped,
  @Beat(event: 'stop', to: stopped)
  wagging,
}
