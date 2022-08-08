import 'package:introduction/introduction.dart';

void main(List<String> arguments) {
  final dogStation = WalkingDogBeatStation();
  print('${dogStation.currentState.singleState}');
  dogStation.$complete();
  print('${dogStation.currentState.singleState}');
}
