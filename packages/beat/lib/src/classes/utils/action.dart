import '../../actions/assign.dart';
import '../../actions/choose.dart';
import '../../actions/raise.dart';
import '../../actions/send.dart';
import '../../utils/function.dart';
import '../beat_state.dart';
import '../beat_station.dart';
import '../event_data.dart';

class ActionHandler<B extends BeatState> {
  const ActionHandler({
    required this.action,
    required this.state,
    required this.event,
    required this.station,
  });
  final dynamic action;
  final B state;
  final EventData event;
  final BeatStation station;

  /// Handle actions by its type
  bool handleAction() {
    return _handleChoose() ||
        _handleAssign() ||
        _handleRaise() ||
        _handleSend() ||
        _handleCallback();
  }

  bool _handleCallback() {
    if (action is! Function) {
      return false;
    }
    execActionMethod(action, state, event);
    return true;
  }

  bool _handleChoose() {
    if (action is! Choose) {
      return false;
    }
    final choosen = (action as Choose).filter(state, event);
    for (final action in choosen) {
      ActionHandler(
        action: action,
        state: state,
        event: event,
        station: station,
      ).handleAction();
    }
    return true;
  }

  bool _handleAssign() {
    if (action is! Assign) {
      return false;
    }
    final assign = action as Assign;
    final context = assign.compute(state, event);
    station.setContext(context);
    return true;
  }

  /// TODO: handle send action
  bool _handleSend() {
    if (action is! Send) {
      return false;
    }
    return true;
  }

  /// TODO: handle raise action
  bool _handleRaise() {
    if (action is! Raise) {
      return false;
    }
    return true;
  }
}
