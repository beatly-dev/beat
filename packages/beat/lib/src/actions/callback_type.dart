/// A reference to a callback function.
typedef BeatAction<State, Context, Event, ActionResult> = ActionResult Function(
  State currentState,
  Context currentContext,
  Event event,
);
