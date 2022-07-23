class BeatConfig {
  final String event;
  final String from;
  final String to;
  final String source;

  BeatConfig({
    required this.event,
    required this.to,
    required this.from,
    required this.source,
  });

  @override
  String toString() {
    return 'from `$from` to `$to` by `$event` source $source';
  }
}
