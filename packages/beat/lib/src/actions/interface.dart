abstract class ActionInterface<State, Context, Event, ActionResult> {
  final ActionResult Function(
    State currentState,
    Context currentContext,
    Event event,
  ) action;

  const ActionInterface(this.action);
}
