import 'default.dart';

/// Define actions to change the context of the state
class AssignAction<State, Context, Event>
    extends DefaultAction<State, Context, Event, Context> {
  const AssignAction(super.action);
}
