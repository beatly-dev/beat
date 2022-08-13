import 'package:beat/beat.dart';

part 'input.beat.dart';

const enterBeat =
    Beat(event: 'enter', to: PubSearch.typed, actions: [AssignAction(enter)]);

@BeatStation(contextType: String)
@enterBeat
enum PubSearch {
  empty,

  @Beat(event: 'clear', to: empty, actions: [AssignAction(clear)])
  typed,
}

enter(state, EventData data) {
  final input = data.data ?? '';
  return input;
}

clear(state, __) {
  return '';
}
