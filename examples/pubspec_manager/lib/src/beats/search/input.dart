import 'package:beat/beat.dart';

part 'input.beat.dart';

@BeatStation(contextType: String)
@typeInput
@clearInput
enum SearchInput {
  empty,

  @searchPackage
  debouncing,

  typed,
}

const clearInput =
    Beat(event: 'clear', to: SearchInput.empty, actions: [AssignAction(clear)]);

const typeInput = Beat(
  event: 'type',
  to: SearchInput.debouncing,
  actions: [AssignAction(enter)],
);

const searchPackage = EventlessBeat(
  to: SearchInput.typed,
  after: Duration(milliseconds: 0),
);

enter(state, EventData data) {
  final input = data.data ?? '';
  return input;
}

clear(state, __) {
  return '';
}
