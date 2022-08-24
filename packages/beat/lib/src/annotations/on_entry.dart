/// An event triggered on entry.
class OnEntry {
  const OnEntry([this.actions = const []]);

  /// Actions to execute on entry.
  final List<dynamic> actions;
}
