import '../../beat.dart';

/// A annotation to define a transition
class Beat<Event, State extends Enum> {
  const Beat({
    required this.event,
    required this.to,
    this.actions = const [],
    this.eventDataType = dynamic,
    this.conditions = const [_alwaysTrueCondition],
  });

  /// Which event will trigger the transition
  final Event event;

  /// Which state will be transitioned to
  final State to;

  /// Which actions will be executed when the transition is triggered
  final List<dynamic> actions;

  /// Which type of data will be passed to actions and invokes.
  final Type eventDataType;

  /// Guard conditions that must be met before the transition is triggered
  final List<bool Function(BeatState<State, dynamic>, EventData)> conditions;
}

bool _alwaysTrueCondition(_, __) => true;
