import 'package:introduction/introduction.dart';

void main(List<String> arguments) {
  final compound = CuteDogBeatStation()..start();
  print(compound.currentState.state);
  compound.send.$leaveHome();
  print(compound.currentState.state);
  print(compound.currentState.of(CuteWalkingDog)?.state);
  compound.send.$speedUp();
  print(compound.currentState.of(CuteWalkingDog)?.state);
  compound.send.$arriveHome();
  print(compound.currentState.of(CuteWalkingDog)?.state);
}
