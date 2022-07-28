/// An annotatino to define invoking services
/// This is used on a state to define which services will be invoked when the state is entered.
class Invokes {
  final List<dynamic> invokes;

  const Invokes([this.invokes = const []]);
}
