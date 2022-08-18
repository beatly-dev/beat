import 'package:flutter_beat/flutter_beat.dart';

part 'input.beat.dart';

@BeatStation(contextType: String)
@typeInput
@clearInput
enum SearchInput {
  empty,

  @searchPackage
  debouncing,

  searching,
}

const clearInput =
    Beat(event: 'clear', to: SearchInput.empty, actions: [AssignAction(clear)]);

const typeInput = Beat(
  event: 'type',
  to: SearchInput.debouncing,
  actions: [AssignAction(enter)],
);

const searchPackage = EventlessBeat(
  to: SearchInput.searching,
  after: Duration(milliseconds: 300),
);

enter(state, EventData data) {
  final input = data.data ?? '';
  return input;
}

clear(_, __) {
  return '';
}
