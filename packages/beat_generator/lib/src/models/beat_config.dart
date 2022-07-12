class BeatConfig {
  final String action;
  final String from;
  final String to;

  BeatConfig({
    required this.action,
    required this.to,
    required this.from,
  });

  @override
  String toString() {
    return 'from `$from` to `$to` by `$action`';
  }
}
