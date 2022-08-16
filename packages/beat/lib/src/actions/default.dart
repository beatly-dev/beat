import '../../beat.dart';

/// Default action implementation
/// All the other actions ahould extend this class
abstract class DefaultAction<State extends BeatState, ActionResult> {
  ActionResult Function(
    State currentState,
    EventData event,
  ) get action;

  const DefaultAction();

  ActionResult execute(
    State currentState,
    EventData event,
  ) {
    return action(currentState, event);
  }
}
