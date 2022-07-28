import '../../beat.dart';

class InvokeFuture<State, Context, Event, Result>
    extends InvokeInterface<State, Context, Event, Result> {
  const InvokeFuture(
    super.invoke, {
    this.onDone = const AfterInvoke(to: '', actions: []),
    this.onError = const AfterInvoke(to: '', actions: []),
  });

  /// Actions to execute when the async operation is completed.
  final AfterInvoke onDone;

  /// Actions to execute when the async operation is cancelled or thrown.
  final AfterInvoke onError;
}

class AfterInvoke<State> {
  final State to;
  final List<dynamic> actions;

  const AfterInvoke({required this.to, required this.actions});

  @override
  String toString() => 'AfterInvokeFuture(to: $to, actions: $actions)';
}
