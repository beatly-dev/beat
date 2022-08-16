import '../../beat.dart';

/// Define actions to change the context of the state
class AssignAction<State extends BeatState, Context>
    extends AssignActionBase<State, Context> {
  const AssignAction(this.action);

  @override
  final Context Function(State currentState, EventData event) action;
}

abstract class AssignActionBase<State extends BeatState, Context>
    extends DefaultAction<State, Context> {
  const AssignActionBase();
}
