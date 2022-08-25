import '../../beat.dart';
import 'models/result.dart';
import 'sender.dart';

enum ParallelStationState {
  started,
}

abstract class ParallelStation
    extends BeatStation<ParallelStationState, dynamic> {
  ParallelStation({required super.machine, super.parent});

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

  @override
  Sender<BeatStation<Enum, dynamic>> get send => throw UnimplementedError();

  /// Parallel stations included here
  List<BeatStation> get parallels;

  /// Start all parallel stations
  @override
  start({Enum? state, EventData? eventData, context}) {
    super.start();
    for (final station in parallels) {
      station.start();
    }
  }

  /// Stop all parallel stations
  @override
  stop() {
    for (final station in parallels) {
      station.stop();
    }
    return super.stop();
  }

  /// Should propagate the event to all parallel stations.
  @override
  EventResult handleEvent<Data>(
    String event,
    String eventId, [
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
}
