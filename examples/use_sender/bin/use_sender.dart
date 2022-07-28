import 'dart:io';
import 'dart:math';

import 'package:beat/beat.dart';

part 'use_sender.beat.dart';

@BeatStation()
enum Assignment {
  @Beat(event: 'finish', to: Assignment.done)
  doing,

  @Beat(event: 'new', to: Assignment.doing)
  done,

  @Beat(event: 'new', to: Assignment.doing)
  retired,
}

void main(List<String> arguments) {
  final station =
      AssignmentBeatStation(AssignmentBeatState(state: Assignment.doing));

  station.addListener(() {
    print("State changed to ${station.currentState}");
  });

  while (true) {
    if (Random().nextBool()) {
      print("Send 'new' event");
      station.send.$new();
    } else {
      print("Send 'finish' event");
      station.send.$finish();
    }
    sleep(Duration(milliseconds: 1000));
  }
}
