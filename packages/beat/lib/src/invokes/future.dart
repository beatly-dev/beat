import '../../beat.dart';

/// Invoke asynchronous services.
/// There should be an async gap to complete services because services can be async.
class InvokeFuture<Event, Result> extends InvokeInterface<Event, Result> {
  const InvokeFuture(
    super.invoke, {
    this.onDone = const AfterInvoke(to: '', actions: []),
    this.onError = const AfterInvoke(to: '', actions: []),
  });

  /// Transition to execute when the async operation is completed.
  final AfterInvoke onDone;

  /// Transition to execute when the async operation is cancelled or thrown.
  final AfterInvoke onError;
}

class AfterInvoke<State> {
  final State to;
  final List<dynamic> actions;

  const AfterInvoke({required this.to, this.actions = const []});

  @override
  String toString() => 'AfterInvokeFuture(to: $to, actions: $actions)';
}
