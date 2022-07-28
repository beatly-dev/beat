import 'package:introduction/introduction.dart';

void main(List<String> arguments) {
  final station = CompoundDogBeatStation();
  print('First state: ${station.currentState}');
  station.send.$leaveHome();
  print('state: ${station.currentState}');
  station.send.$arriveHome();
  print('state: ${station.currentState}');
  station.resetState();
  print('state: ${station.currentState}');
  station.send.$leaveHome();
  print('state: ${station.currentState}');
  station.send.$speedUp();
  print('state: ${station.onWalkingDogCompound.currentState}');
  station.send.$suddenStop();
  print('state: ${station.onWalkingDogCompound.currentState}');
}
