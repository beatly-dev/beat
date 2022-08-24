import 'package:meta/meta.dart';

import '../../beat.dart';
import '../utils/function.dart';

/// Define actions to change the context of the state
/// This is same as `if`/`else if`/`else`.
/// The first matching actions will only be executed.
@sealed
class Choose {
  const Choose(this.conditionals);

  final List<ChooseItem> conditionals;

  /// Returns the first matching actions to execute.
  List<dynamic> filter(BeatState state, EventData event) {
    return conditionals
        .firstWhere(
          (conditional) => conditional.tests.every(
            (test) => execActionMethod<bool>(test, state, event) ?? false,
          ),
          orElse: () => ChooseItem(actions: []),
        )
        .actions;
  }
}

@sealed
class ChooseItem {
  /// Conditions to test
  /// If all the conditions are met, the [actions] will be executed.
  final List<dynamic> tests;

  /// Same syntax with an [Beat.actions] field
  final List<dynamic> actions;

  const ChooseItem({
    this.tests = const [_alwaysTrue],
    required this.actions,
  });
}

bool _alwaysTrue(_, __) => true;
