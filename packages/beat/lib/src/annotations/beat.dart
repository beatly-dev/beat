bool alwaysTrueCondition(_, __) => true;

/// A annotation to define a transition
/// One state can have multiple [Beat]
/// Multiple [Beat] can have a same event name
class Beat {
  const Beat({
    required this.to,
    this.event = '',
    this.actions = const [],
    this.eventDataType = dynamic,
    this.conditions = const [],
  });

  /// Which event will trigger the transition
  final String event;

  /// Which state will be transitioned to
  final Enum to;

  /// Which actions will be executed when the transition is triggered
  final List<dynamic> actions;

  /// Which type of data will be passed to actions and services.
  final Type eventDataType;

  /// Guard conditions that must be met before the transition is triggered
  final List<dynamic> conditions;
}

/// An eventless beat transition annotation
/// This defines the transient transition between states.
/// Users can set the delay time before the transition is triggered.
class EventlessBeat extends Beat {
  const EventlessBeat({
    required super.to,
    super.actions = const [],
    super.eventDataType = dynamic,
    super.conditions = const [],
    this.after,
  }) : super();

  /// Can be a [Duration] or a callback [Function]
  /// Possible forms of a callback [Function]
  /// - [Duration] Function([BeatState], [EventData])
  /// - [Duration] Function([BeatState])
  /// - [Duration] Function([EventData])
  /// - [Duration] Function()
  final dynamic after;
}
