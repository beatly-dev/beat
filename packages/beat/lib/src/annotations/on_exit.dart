/// An event triggered on exit.
class OnExit {
  const OnExit([this.actions = const []]);

  /// Actions to execute on exit.
  final List<dynamic> actions;
}
