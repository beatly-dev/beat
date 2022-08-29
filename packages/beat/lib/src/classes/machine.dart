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
  CurrentState? get currentState => _activeStations.currentState;

  /// List of events that can be invoked on the current state.
  Set<String> get nextEvents => _activeStations.nextEvents;

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
    } else {
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
    _activeStations.all?.recurse((station) => station.checkGuardedEventless());
  }

  /// Cancel and remove a delayed event
  cancelDelayed(int eventId) {
    _activeStations.all?.recurse((station) => station.cancelDelayed(eventId));
  }
}

class _ActiveStations {
  const _ActiveStations(this.root);
  final BeatStation root;

  /// Get currently active station
  _ActiveStationTree? get all => _findAllActive(root);

  _ActiveStationTree? _findAllActive(BeatStation station) {
    if (station.started) {
      final children = <_ActiveStationTree>[];
      final child = station.child;
      if (child != null) {
        final childNode = _findAllActive(child);
        if (childNode != null) {
          children.add(childNode);
        }
      }
      if (station is ParallelBeatStation) {
        for (final child in station.parallels) {
          final childNode = _findAllActive(child);
          if (childNode != null) {
            children.add(childNode);
          }
        }
      }
      return _ActiveStationTree(station: station, children: children);
    }
    return null;
  }

  Set<String> get nextEvents => all?.nextEvents ?? {};

  /// Get currently active state
  /// - Including all active stations
  CurrentState? get currentState => all?.currentState;

  /// Returns the station with the given id.
  T? stationById<T extends BeatStation>(String id) => all?.findStationById(id);

  /// Returns the station holding the given enum.
  T? stationOf<T extends BeatStation>(Type type) =>
      all?.findStationByType(type);

  /// Returns the beat state holding the given enum.
  T? stateOf<T extends BeatState>(Type type) =>
      all?.findStationByType(type)?.currentState as T;
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

class _ActiveStationTree {
  final BeatStation station;
  final List<_ActiveStationTree> children;
  _ActiveStationTree({
    required this.station,
    this.children = const [],
  });

  recurse(Function(BeatStation) callback) {
    callback(station);
    for (final child in children) {
      child.recurse(callback);
    }
  }

  CurrentState get currentState {
    final childStates = <CurrentState>[];
    for (final child in children) {
      childStates.add(child.currentState);
    }
    final currentState = CurrentState(
      id: station.id,
      state: station.currentState,
      children: childStates,
    );
    return currentState;
  }

  Set<String> get nextEvents {
    final nextEvents = <String>{};
    if (station is! ParallelBeatStation) {
      nextEvents.addAll(
        station.normalBeats
            .map((beat) => beat.event)
            .where((event) => event.isNotEmpty),
      );
      nextEvents.addAll(
        station.stationBeats
            .map((beat) => beat.event)
            .where((event) => event.isNotEmpty),
      );
    }
    for (final child in children) {
      nextEvents.addAll(child.nextEvents);
    }
    return nextEvents;
  }

  T? findStation<T extends BeatStation>() {
    if (station is T) {
      return station as T;
    }
    for (final child in children) {
      final station = child.findStation<T>();
      if (station != null) {
        return station;
      }
    }
    return null;
  }

  T? findStationById<T extends BeatStation>(String id) {
    if (station.id == id) {
      return station as T;
    }
    for (final child in children) {
      final station = child.findStationById<T>(id);
      if (station != null) {
        return station;
      }
    }
    return null;
  }

  T? findStationByType<T extends BeatStation>(Type type) {
    if (station.currentState.state.runtimeType == type) {
      return station as T;
    }
    for (final child in children) {
      final station = child.findStationByType<T>(type);
      if (station != null) {
        return station;
      }
    }
    return null;
  }
}

class CurrentState {
  final String id;
  final BeatState state;
  final List<CurrentState> children;

  CurrentState({
    required this.id,
    required this.state,
    this.children = const [],
  });

  @override
  String toString() =>
      ' { station: $id, state: $state, nested: [ ${children.map((child) => child.toString()).join(',')} ] } ';
}
