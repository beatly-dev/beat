import '../actions/default.dart';

class Beat<Event, State, Context, Action extends DefaultAction> {
  const Beat({required this.event, required this.to, this.actions = const []});

  final Event event;
  final State to;
  final List<dynamic> actions;
}
