/// Main annotation
/// This makes the entire `enum` to become a beat station.
class Station<Ext> {
  const Station({
    this.initalExtended,
    this.withFlutter = false,
  });

  /// A type of the context.
  final Ext? initalExtended;
  final bool withFlutter;
}
