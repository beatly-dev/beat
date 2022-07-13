import 'dart:io';
import 'dart:math';

import 'states/bulb.state.dart';

void main(List<String> arguments) {
  final station = BulbStation(Bulb.turnedOff);
  station.attach(() {
    print("${station.currentState}");
  });
  while (true) {
    station.when(
      turnedOff: (modifier) =>
          Random().nextBool() ? modifier.$turnOn() : modifier.$destroy(),
      turnedOn: (modifier) =>
          Random().nextBool() ? modifier.$turnOff() : modifier.$destroy(),
      broken: () => print("Broken"),
      or: () => print("Nothing"),
    );
    sleep(Duration(milliseconds: 500));
  }
}
