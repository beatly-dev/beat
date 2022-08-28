import '../../beat.dart';
import 'models/result.dart';

enum ParallelStationState {
  started,
}

abstract class ParallelBeatStation
    extends BeatStation<ParallelStationState, dynamic> {
  ParallelBeatStation({required super.machine, super.parent});

  @override
  BeatStation<Enum, dynamic>? get child => null;

  /// Check if all the parallel stations are done.
  @override
  bool get done =>
      parallels.fold(true, (done, station) => done && station.done);

  /// Entry atcions should be defined in the children station.
  @override
  List get entry => [];

  /// Exit atcions should be defined in the children station.
  @override
  List get exit => [];

  @override
  BeatState<ParallelStationState, dynamic> get initialState => BeatState(
        ParallelStationState.started,
        null,
        this,
      );

  /// Parallel stations included here
  List<BeatStation> get parallels;

  /// Start all parallel stations
  @override
  start({Enum? state, EventData? eventData, context}) {
    if (started) {
      return;
    }
    started = true;
    for (final station in parallels) {
      station.start();
    }
  }

  /// Stop all parallel stations
  @override
  stop([bool executeStateExit = true]) {
    if (!started) {
      return;
    }
    for (final station in parallels) {
      station.stop(executeStateExit);
    }
    started = false;
  }

  /// Should propagate the event to all parallel stations.
  @override
  EventResult handleEvent<Data>(
    String event,
    int eventId, [
    Data? data,
    Duration after = const Duration(milliseconds: 0),
  ]) {
    bool handled = false;
    for (final station in parallels) {
      /// all parallel station must receive the event
      /// So [BeatStation.handleEvent] should be called earlier than
      /// [handled] is evaluated.
      handled =
          station.handleEvent(event, eventId, data, after).handled || handled;
    }
    if (handled) {
      return EventResult.handled();
    }
    return EventResult.notHandled();
  }

  /// Should propagate the checking request to all parallel stations.
  @override
  bool checkGuardedEventless() {
    bool handled = false;
    for (final station in parallels) {
      /// all parallel station must receive the event
      handled = station.checkGuardedEventless() || handled;
    }
    return handled;
  }

  /// This shouldn't be called in any time
  @override
  handleBeat(Enum nextState, EventData eventData, [List actions = const []]) {
    throw UnimplementedError('ParallelStation.handleBeat should not be called');
  }

  /// This shouldn't be called in any time
  @override
  handleTransition(ParallelStationState nextState, EventData eventData) {
    throw UnimplementedError(
      'ParallelStation.handlTransition should not be called',
    );
  }

  @override
  Map<ParallelStationState, OnEntry> get stateEntry =>
      throw UnimplementedError();

  @override
  Map<ParallelStationState, OnExit> get stateExit => throw UnimplementedError();

  @override
  Map<ParallelStationState, List<Services>> get stateServices =>
      throw UnimplementedError();

  @override
  Map<ParallelStationState, List<Beat>> get stateToBeat =>
      throw UnimplementedError();

  @override
  List<Beat> get stationBeats => throw UnimplementedError();
}
