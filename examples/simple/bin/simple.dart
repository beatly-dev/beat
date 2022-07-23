import 'dart:io';

import 'states/bulb.state.dart';

void main(List<String> arguments) {
  final station = BulbBeatStation(BulbBeatState(state: Bulb.turnedOff));
  station.addListener(() {
    print("${station.currentState}");
  });
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
    sleep(Duration(milliseconds: 500));
  }
}
