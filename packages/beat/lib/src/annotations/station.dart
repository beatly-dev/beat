/// Main annotation
/// This makes the entire `enum` to become a beat station.
class Station<State extends Enum, Context> {
  const Station({
    this.initialState,
    this.initialContext,
    this.id,
    this.contextType = dynamic,
    this.withFlutter = false,
  });

  /// Station id to distinguish
  final String? id;

  /// Initial enum state
  final State? initialState;

  /// Initial Context data
  final Context? initialContext;

  /// A type of the context.
  final Type contextType;

  /// Whether to use flutter widgets or not.
  final bool withFlutter;
}
