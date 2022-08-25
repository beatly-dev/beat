import '../../beat.dart';
import 'sender.dart';

enum ParallelStationState {
  started,
}

abstract class ParallelStation
    extends BeatStation<ParallelStationState, dynamic> {
  ParallelStation({required super.machine, super.parent});

  @override
  BeatStation<Enum, dynamic>? get child => null;

  @override
  bool get done;

  @override
  List get entry => [];

  @override
  List get exit => [];

  @override
  BeatState<ParallelStationState, dynamic> get initialState => BeatState(
        ParallelStationState.started,
        null,
        this,
      );

  @override
  Sender<BeatStation<Enum, dynamic>> get send => throw UnimplementedError();

  List<BeatStation> get parallels;

  @override
  start({Enum? state, EventData? eventData, context}) {
    super.start();
    for (final station in parallels) {
      station.start();
    }
  }

  @override
  stop() {
    for (final station in parallels) {
      station.stop();
    }
    return super.stop();
  }

  /// Should propagate the event to all parallel stations.
  @override
  bool handleEvent<Data>(
    String event, [
    Data? data,
    Duration after = const Duration(milliseconds: 0),
  ]) {
    bool handled = false;
    for (final station in parallels) {
      /// all parallel station must receive the event
      /// So [BeatStation.handleEvent] should be called earlier than
      /// [handled] is evaluated.
      handled = station.handleEvent(event, data, after) || handled;
    }
    return handled;
  }

  /// Should propagate the checking request to all parallel stations.
  @override
  checkGuardedEventless() {
    for (final station in parallels) {
      station.checkGuardedEventless();
    }
  }

  @override
  handleBeat(Enum nextState, EventData eventData, [List actions = const []]) {
    throw UnimplementedError('ParallelStation.handleBeat should not be called');
  }

  @override
  handleTransition(ParallelStationState nextState, EventData eventData) {
    throw UnimplementedError(
      'ParallelStation.handlTransition should not be called',
    );
  }
}
