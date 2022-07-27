import '../../beat.dart';

class InvokeFuture<State, Context, Event, Result>
    extends InvokeInterface<State, Context, Event, Result> {
  const InvokeFuture(
    super.invoke, {
    this.onDone = const AfterInvokeFuture(to: '', actions: []),
    this.onError = const AfterInvokeFuture(to: '', actions: []),
  });

  /// Actions to execute when the async operation is completed.
  final AfterInvokeFuture onDone;

  /// Actions to execute when the async operation is cancelled or thrown.
  final AfterInvokeFuture onError;
}

class AfterInvokeFuture<State> {
  final State to;
  final List<dynamic> actions;

  const AfterInvokeFuture({required this.to, required this.actions});

  @override
  String toString() => 'AfterInvokeFuture(to: $to, actions: $actions)';
}
