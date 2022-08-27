import '../../beat.dart';

/// The root container of the beat stations.
/// This will handle the state transitions and the event dispatching.
/// Invoked services and delayed events are also handled here.
abstract class BeatMachine {
  BeatMachine();

  /// station id to station
  BeatStation get root;

  /// Sender to send event
  MachineSender get send;

  /// Get currently active class
  _ActiveStations get _activeStations => _ActiveStations(root);

  /// Get currently active state
  /// - Including all active stations
  List<BeatState> get currentState => _activeStations.currentState;

  /// Returns the station with the given id.
  T? stationById<T extends BeatStation>(String id) =>
      _activeStations.stationById<T>(id);

  /// Returns the station holding the given enum.
  T? stationOf<T extends BeatStation>(Type type) =>
      _activeStations.stationOf<T>(type);

  /// Returns the beat state holding the given enum.
  T? stateOf<T extends BeatState>(Type type) =>
      _activeStations.stateOf<T>(type);

  List<EventData> get eventHistory => _eventHistory;
  final _eventHistory = <EventData>[];

  int _eventId = 0;

  int _previousEventHistoryLength = 0;

  /// Forward event to currently active root station
  int _forward<Data>(
    String event, {
    Data? data,
    Duration after = const Duration(),
    Type? target,
  }) {
    final eventId = _eventId++;

    var handled = false;

    if (target != null) {
      final station = _activeStations.stationOf(target);
      handled =
          station?.handleEvent(event, eventId, data, after).handled ?? false;
    }

    if (!handled) {
      handled = root.handleEvent(event, eventId, data, after).handled;
    }

    _previousEventHistoryLength = _eventHistory.length;
    if (handled) {
      _eventHistory.add(EventData(event: event, data: data));

      /// Check guarded eventless
      checkGuardedEventless();
    }

    return eventId;
  }

  bool get changed => _previousEventHistoryLength != _eventHistory.length;

  /// Check active stations' queued eventless events
  checkGuardedEventless() {
    for (final station in _activeStations.all()) {
      station.checkGuardedEventless();
    }
  }

  /// Cancel and remove a delayed event
  cancelDelayed(int eventId) {
    for (final station in _activeStations.all()) {
      station.cancelDelayed(eventId);
    }
  }
}

class _ActiveStations {
  const _ActiveStations(this.root);
  final BeatStation root;

  /// Get currently active class
  List<BeatStation> all() {
    return _findAllActive(root);
  }

  List<BeatStation> _findAllActive(BeatStation station) {
    final active = <BeatStation>[];
    if (station.started) {
      active.add(station);
      if (station.child != null) {
        active.addAll(_findAllActive(station.child!));
      }
    }
    return active;
  }

  /// Get currently active state
  /// - Including all active stations
  List<BeatState> get currentState =>
      all().map((station) => station.currentState).toList();

  /// Returns the station with the given id.
  T? stationById<T extends BeatStation>(String id) =>
      _findStationById(id, root);

  T? _findStationById<T extends BeatStation>(String id, BeatStation station) {
    if (station.id == id) {
      return station as T;
    }
    if (station.child != null) {
      return _findStationById(id, station.child!);
    }
    return null;
  }

  /// Returns the station holding the given enum.
  T? stationOf<T extends BeatStation>(Type type) =>
      _findStationByEnum(type, root);

  T? _findStationByEnum<T extends BeatStation>(Type type, BeatStation station) {
    if (station.currentState.state.runtimeType == type) {
      return station as T;
    }
    if (station.child != null) {
      return _findStationByEnum(type, station.child!);
    }
    return null;
  }

  /// Returns the beat state holding the given enum.
  T? stateOf<T extends BeatState>(Type type) => _findStateByEnum(type, root);

  T? _findStateByEnum<T extends BeatState>(Type type, BeatStation station) {
    if (station.currentState.state.runtimeType == type) {
      return station.currentState as T;
    }
    if (station.child != null) {
      return _findStateByEnum(type, station.child!);
    }
    return null;
  }
}

abstract class MachineSender {
  const MachineSender(this.machine);
  final BeatMachine machine;
  int call<Data>(
    String event, {
    Data? data,
    Duration after = const Duration(),
    Type? target,
  }) =>
      machine._forward(event, data: data, after: after, target: target);
}
