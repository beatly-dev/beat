/// Main annotation
/// This makes the entire `enum` to become a beat station.
class BeatStation<State, Context> {
  const BeatStation({
    this.contextType = Null,
  });

  /// A type of the context.
  final Type contextType;
}
