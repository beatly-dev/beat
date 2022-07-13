class Beat<A, T, C> {
  const Beat({required this.event, required this.to, this.assign});

  final A event;
  final T to;
  final C Function(C prev)? assign;
}
