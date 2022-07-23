class Beat<Event, State, Context> {
  const Beat({required this.event, required this.to, this.actions = const []});

  final Event event;
  final State to;
  final List<dynamic> actions;
}
