import '../../beat.dart';

abstract class InvokeInterface<Event, InvokeResult> {
  final InvokeResult Function(BeatState, Event) invoke;

  const InvokeInterface(this.invoke);

  InvokeResult invokeWith(BeatState state, Event event) {
    return invoke(state, event);
  }
}
