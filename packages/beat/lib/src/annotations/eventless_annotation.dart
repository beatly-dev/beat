import 'beat_annotation.dart';

/// An eventless beat transition annotation
/// This defines the transient transition between states.
/// Users can set the delay time before the transition is triggered.
/// The first transition that matches the condition and the delay time is triggered.
class EventlessBeat {
  const EventlessBeat({this.beats = const []});
  final List<Eventless> beats;
}

/// An eventless transition's detail
class Eventless extends Beat {
  const Eventless({
    required super.to,
    super.actions,
    super.eventDataType,
    super.conditions,
    this.delay = const Duration(milliseconds: 0),
  }) : super(event: '');

  final Duration delay;
}
