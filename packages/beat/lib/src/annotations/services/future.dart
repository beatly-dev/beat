/// Invoke asynchronous services.
/// There should be an async gap to complete services because services can be async.
class AsyncService<Event, Result> {
  const AsyncService(
    Function service, {
    this.onDone = const After(),
    this.onError = const After(),
  });

  /// Transition to execute when the async operation is completed.
  final After onDone;

  /// Transition to execute when the async operation is cancelled or thrown.
  final After onError;
}

class After<State extends Enum> {
  /// If this is null only the actions are executed
  final State? to;
  final List<dynamic> actions;

  const After({this.to, this.actions = const []});

  @override
  String toString() => 'AfterInvokeFuture(to: $to, actions: $actions)';
}
