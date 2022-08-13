import 'package:beat/beat.dart';

part 'input.beat.dart';

const enterBeat =
    Beat(event: 'enter', to: PubSearch.entered, actions: [AssignAction(enter)]);

@BeatStation(contextType: String)
@enterBeat
enum PubSearch {
  idle,

  @Beat(event: 'clear', to: idle, actions: [AssignAction(clear)])
  entered,
}

enter(state, EventData data) {
  final input = data.data ?? '';
  return input;
}

clear(state, __) {
  return '';
}
