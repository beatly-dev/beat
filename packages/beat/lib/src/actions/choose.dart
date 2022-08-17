import '../../beat.dart';

/// Define actions to change the context of the state
/// This is same as `if`/`else if`/`else`.
/// The first matching actions will only be executed.
class ChooseAction<State extends BeatState> extends ChooseActionBase<State> {
  const ChooseAction(this.conditionals);

  @override
  Function(State currentState, EventData event) get action =>
      throw UnimplementedError();

  final List<ChooseActionItem> conditionals;

  @override
  List<dynamic> execute(State currentState, EventData event) {
    for (final element in conditionals) {
      if (element.conditions.every((element) => element(currentState, event))) {
        return element.actions;
      }
    }
    return [];
  }
}

class ChooseActionItem {
  final List<bool Function(BeatState, EventData)> conditions;
  final List<dynamic> actions;

  const ChooseActionItem({
    this.conditions = const [_alwaysTrue],
    required this.actions,
  });
}

bool _alwaysTrue(_, __) => true;

abstract class ChooseActionBase<State extends BeatState>
    extends DefaultAction<State, dynamic> {
  const ChooseActionBase();
}
