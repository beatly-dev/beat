/// Main annotation
/// This makes the entire `enum` to become a beat station.
class BeatStation {
  const BeatStation({this.contextType = Null});

  /// A type of the context.
  final Type contextType;
}

const station = BeatStation();
