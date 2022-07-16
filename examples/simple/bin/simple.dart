import 'dart:io';
import 'dart:math';

import 'states/bulb.state.dart';

void main(List<String> arguments) {
  final station = BulbStation(Bulb.turnedOff);
  station.attach(() {
    print("${station.currentState}");
  });
  while (true) {
    print('next events: ${station.nextEvents}');
    print('done: ${station.done}');
    station.when(
      turnedOff: (modifier) async =>
          Random().nextBool() ? modifier.$turnOn() : station.$destroy(),
      turnedOn: (modifier) =>
          Random().nextBool() ? modifier.$turnOff() : station.$destroy(),
      broken: () => print("Broken"),
      or: () => print("Nothing"),
    );
    sleep(Duration(milliseconds: 500));
  }
}
