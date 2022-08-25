import '../../beat.dart';

/// The root container of the beat stations.
/// This will handle the state transitions and the event dispatching.
/// Invoked services and delayed events are also handled here.
class BeatMachine {
  /// station id to station
  final _idToStation = const <String, BeatStation>{};

  /// Enum to station
  final _enumToStation = const <Type, BeatStation>{};

  /// Get currently active class
  Iterable<BeatStation> get _activeStations =>
      _idToStation.values.where((station) => station.started);

  /// Get currently active state
  /// - Including all active stations
  List<BeatState> get currentState =>
      _activeStations.map((station) => station.currentState).toList();

  /// Returns the station with the given id.
  T? stationById<T extends BeatStation>(String id) => _idToStation[id] as T?;

  /// Returns the station holding the given enum.
  T? stationOf<T extends BeatStation>(Type type) => _enumToStation[type] as T?;

  /// Returns the beat state holding the given enum.
  T? stateOf<T extends BeatState>(Type type) =>
      stationOf(type)?.currentState as T?;

  List<EventData> get eventHistory => _eventHistory;
  final _eventHistory = <EventData>[];

  int _eventId = 0;

  /// Forward event to currently active root station
  int _forward<Data>(
    String event, {
    Data? data,
    Duration after = const Duration(),
  }) {
    final root = _activeStations.where((station) => station.parent == null);
    final eventId = _eventId++;
    for (final station in root) {
      station.handleEvent(event, eventId, data, after);
    }
    _eventHistory.add(EventData(event: event, data: data));

    /// Check guarded eventless
    checkGuardedEventless();
    return eventId;
  }

  /// Check active stations' queued eventless events
  checkGuardedEventless() {
    for (final station in _activeStations) {
      station.checkGuardedEventless();
    }
  }

  /// Cancel and remove a delayed timer
  cancelDelayed(int eventId) {
    for (final station in _activeStations) {
      station.cancelDelayed(eventId);
    }
  }

  MachineSender get send => MachineSender(this);
}

class MachineSender {
  const MachineSender(this.machine);
  final BeatMachine machine;
  call<Data>(String event, {Data? data, Duration after = const Duration()}) =>
      machine._forward(event, data: data, after: after);
}
