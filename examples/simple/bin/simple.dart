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
    switch (station.currentState.state) {
      case Bulb.turnedOff:
        station.turnedOff.$turnOn();
        break;
      case Bulb.turnedOn:
        station.turnedOn.$turnOff();
        break;
      case Bulb.broken:
        break;
    }
    if (rand.nextInt(100000) < 10000) {
      station.$destroy();
    }
    sleep(Duration(milliseconds: 500));
  }
}
