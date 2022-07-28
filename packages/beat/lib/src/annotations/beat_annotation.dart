import '../actions/default.dart';

/// A annotation to define a transition
class Beat<Event, State, Context, Action extends DefaultAction> {
  const Beat({required this.event, required this.to, this.actions = const []});

  /// Which event will trigger the transition
  final Event event;

  /// Which state will be transitioned to
  final State to;

  // Which actions will be executed when the transition is triggered
  final List<dynamic> actions;
}
