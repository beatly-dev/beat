import 'generated_beat_state.dart';

/// For `BeatStaion`'s common behavior
abstract class GeneratedBeatStation<BaseState,
    BeatState extends GeneratedBeatState, Context> {
  GeneratedBeatStation(this._initialState);

  final List<BeatState> _history = [];
  List<BeatState> get history => [..._history];

  final BeatState _initialState;
  BeatState get initialState => _initialState;
  BeatState get currentState => history.isEmpty ? _initialState : history.last;
}
