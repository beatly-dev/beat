import 'dart:async';

class Beat<A, T, C> {
  const Beat({required this.event, required this.to, this.assign});

  final A event;
  final T to;
  final FutureOr<C> Function(T currentState, C prevContext, String event)?
      assign;
}
