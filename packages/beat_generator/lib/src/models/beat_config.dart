class BeatConfig<C> {
  final String event;
  final String from;
  final String to;
  final String assign;

  BeatConfig({
    required this.event,
    required this.to,
    required this.from,
    this.assign = '',
  });

  @override
  String toString() {
    return 'from `$from` to `$to` by `$event`';
  }
}
