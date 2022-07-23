import 'dart:io';
import 'dart:math';

import 'states/bulb.state.dart';

void main(List<String> arguments) {
  final station = BulbBeatStation(BulbBeatState(state: Bulb.turnedOff));
  station.addListener(() {
    print("${station.currentState}");
  });
  final rand = Random();
  while (true) {
    if (rand.nextInt(100000) < 10000) {
      station.$destroy();
      break;
    }
    if (station.isTurnedOff) {
      station.turnedOff.$turnOn();
    } else if (station.isTurnedOn) {
      station.turnedOn.$turnOff();
    }
    sleep(Duration(milliseconds: 500));
  }
  print("History ${station.history}");
}
