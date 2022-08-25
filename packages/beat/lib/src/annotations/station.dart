/// Main annotation
/// This makes the entire `enum` to become a beat station.
class Station<State extends Enum, Context> {
  const Station({
    this.initialState,
    this.initalContext,
    this.id,
    this.withFlutter = false,
  });

  /// A type of the context.
  final Context? initalContext;
  final State? initialState;
  final String? id;
  final bool withFlutter;
}
