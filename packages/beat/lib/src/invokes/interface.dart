abstract class InvokeInterface<State, Context, Event, InvokeResult> {
  final InvokeResult Function(State, Context, Event) invoke;

  const InvokeInterface(this.invoke);

  InvokeResult invokeWith(State state, Context context, Event event) {
    return invoke(state, context, event);
  }
}
