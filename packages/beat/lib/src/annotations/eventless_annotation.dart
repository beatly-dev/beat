import 'beat_annotation.dart';

/// An eventless beat transition annotation
/// This defines the transient transition between states.
/// Users can set the delay time before the transition is triggered.
/// The first transition that matches the condition and the delay time is triggered.
class EventlessBeat extends Beat {
  const EventlessBeat({
    required super.to,
    super.actions = const [],
    super.eventDataType = dynamic,
    super.conditions = const [],
    this.after = const Duration(milliseconds: 0),
  }) : super(event: '');

  final Duration after;
}
