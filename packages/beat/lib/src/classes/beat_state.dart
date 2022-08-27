import 'beat_station.dart';

/// Default state class
class BeatState<State extends Enum, Context> {
  const BeatState(this.state, this.context, this.station);

  /// An enum that represents the state
  final State state;

  /// An extra data
  final Context? context;

  /// Station holding the state
  final BeatStation station;

  BeatState<State, Context> copyWith({
    State? state,
    Context? context,
  }) =>
      BeatState(
        state ?? this.state,
        context ?? this.context,
        station,
      );

  BeatState<State, Context> copyWithContext({
    State? state,
    Context? context,
  }) =>
      BeatState(
        state ?? this.state,
        context,
        station,
      );

  T? of<T extends BeatState>(Type enumType) => station.stateOf(enumType);

  @override
  String toString() => '{state: $state, context: $context}';
}
