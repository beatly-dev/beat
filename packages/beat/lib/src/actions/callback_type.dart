typedef BeatAction<State, Context, Event, ActionResult> = ActionResult Function(
  State currentState,
  Context currentContext,
  Event event,
);
