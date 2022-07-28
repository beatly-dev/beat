/// Default action implementation
/// All the other actions ahould extend this class
class DefaultAction<State, Context, Event, ActionResult> {
  final ActionResult Function(
    State currentState,
    Context currentContext,
    Event event,
  ) action;

  const DefaultAction(this.action);

  ActionResult execute(
    State currentState,
    Context currentContext,
    Event event,
  ) {
    return action(currentState, currentContext, event);
  }
}
