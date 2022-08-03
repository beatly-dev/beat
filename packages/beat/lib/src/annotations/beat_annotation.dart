/// A annotation to define a transition
class Beat<Event, State extends Enum, Context> {
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

  // Which actions will be executed when the transition is triggered
  final List<dynamic> actions;

  // Which type of data will be passed to actions and invokes.
  final Type eventDataType;

  final List<bool Function()> conditions;
}

bool _alwaysTrueCondition() => true;
