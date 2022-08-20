/// Main annotation
/// This makes the entire `enum` to become a beat station.
class BeatStation<State, Context> {
  const BeatStation({
    this.contextType = dynamic,
    this.withFlutter = false,
  });

  /// A type of the context.
  final Type contextType;
  final bool withFlutter;
}
