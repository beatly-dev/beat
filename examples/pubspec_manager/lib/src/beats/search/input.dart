import 'package:beat/beat.dart';

part 'input.beat.dart';

@BeatStation(contextType: String)
enum PubSearch {
  @Beat(event: 'enter', to: PubSearch.entered, actions: [AssignAction(enter)])
  idle,

  @Beat(event: 'clear', to: idle, actions: [AssignAction(clear)])
  @Beat(event: 'enter', to: PubSearch.entered, actions: [AssignAction(enter)])
  entered,
}

enter(state, EventData data) {
  final input = data.data ?? '';
  return input;
}

clear(state, __) {
  return '';
}
