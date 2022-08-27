import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import '../../beat.dart';
import '../utils/function.dart';
import 'models/result.dart';
import 'utils/action.dart';

/// TODO: hanlde services
/// TODO: Split Logic
/// Common logic of beat station
abstract class BeatStation<State extends Enum, Context> {
  BeatStation({required this.machine, this.parent});

  final BeatMachine machine;
  final BeatStation? parent;

  @protected
  BeatStation? get child;

  BeatState<State, Context> get initialState;
  BeatState<State, Context> get currentState =>
      stateHistory.isEmpty ? initialState : stateHistory.last;
  List<BeatState<State, Context>> get stateHistory => _stateHistory;
  final _stateHistory = <BeatState<State, Context>>[];
  final _eventHistory = <EventData>[];

  setEnumState(State state) {
    final nextState = currentState.copyWith(state: state);
    setState(nextState);
  }

  setContext(Context? context) {
    final nextState = currentState.copyWithContext(context: context);
    setState(nextState);
  }

  setState(BeatState<State, Context> nextState) {
    stateHistory.add(nextState);
  }

  bool get started => _started;
  bool _started = false;

  String get id => '$hashCode';

  @protected
  List<dynamic> get entry;

  @protected
  List<dynamic> get exit;

  /// Start the state machine
  /// 1. Start the station
  /// 2. Execute machine's entry actions
  /// 3. Transition to initial state
  /// 4. Start a child station
  @mustCallSuper
  start({final State? state, EventData? eventData, final Context? context}) {
    if (_started) {
      return;
    }
    _started = true;
    final startingState = initialState.copyWith(state: state, context: context);
    eventData ??= EventData(event: 'beat.${State}Station($id).exit');

    _executeActions(
      entry,
      startingState,
      eventData,
    );

    handleBeat(startingState.state, eventData);
    child?.start();
  }

  /// Stop the state machine
  /// Reverse the order of steps in start()
  @mustCallSuper
  stop() {
    if (!_started) {
      return;
    }
    child?.stop();
    _executeActions(
      exit,
      currentState,
      EventData(event: 'beat.${State}Station($id).exit'),
    );
    _started = false;
  }

  /// Check the machine reaches `final` state
  bool get done;

  /// Get the [BeatState] holding the given enum type.
  /// Return null if that state is not found on the entire machine
  /// or the station is not yet started.
  T? stateOf<T extends BeatState>(Type enumType) => machine.stateOf(enumType);

  /// Queue for delayed events. This includes two types of events:
  /// 1. Sent by `send(event, after: duration)` syntax
  /// 2. Eventless events with a delay
  final _delayed = Queue<Timer>();
  final _delayedIds = <int, Timer>{};

  /// Add delayed events
  addDelayed(Function callback, Duration after, [int? eventId]) {
    if (after.inMicroseconds == 0) {
      return callback();
    }
    final state = currentState.state;
    final timer = Timer(after, () {
      /// Execute delayed event only if the state is still the same
      if (state != currentState.state) {
        return;
      }
      callback();
    });
    _delayed.add(timer);

    /// Add timer id to allow programmatically cancel the timer
    if (eventId != null) {
      _delayedIds.addAll({eventId: timer});
    }
  }

  /// Cancel and remove a delayed timer
  cancelDelayed(int eventId) {
    final delayed = _delayedIds[eventId];
    if (delayed != null) {
      delayed.cancel();
      _delayedIds.remove(eventId);
      _delayed.remove(delayed);
    }
  }

  /// Clear delayed events
  clearDelayed() {
    for (var timer in _delayed) {
      timer.cancel();
    }
    _delayed.clear();
  }

  Map<State, List<EventlessBeat>> get _stateToEventless => stateToBeat.map(
        (state, list) =>
            MapEntry(state, list.whereType<EventlessBeat>().toList()),
      );

  List<EventlessBeat> get eventlessBeats =>
      _stateToEventless[currentState.state] ?? [];

  /// List of eventless events with guards and no delays.
  final List<EventlessBeat> guardedEventlesses = [];

  bool _isDelayedBeat(
    EventlessBeat beat, [
    EventData? event,
  ]) {
    event ??= EventData(
      event: 'beat.${State}Station($id).${currentState.state}.eventless',
    );

    final duration =
        execActionMethod<Duration>(beat.after, currentState, event) ??
            Duration.zero;

    return duration.inMicroseconds > 0;
  }

  /// Check eventless events' guards
  bool checkGuardedEventless() {
    /// From all queued eventless events,
    for (final eventless in guardedEventlesses) {
      final eventData = EventData(
        event:
            'beat.${State}Station($id).${currentState.state}.guardedEventless',
      );

      final test = _passGuards(eventless, eventData);

      /// if all condition matches then execute the transition
      if (test) {
        handleBeat(eventless.to, eventData, eventless.actions);
        return true;
      }
    }
    return false;
  }

  List<Beat> get stationBeats;

  /// Current state to beat event
  Map<State, List<Beat>> get stateToBeat;

  /// Beat events in the current state
  List<Beat> get normalBeats => stateToBeat[currentState.state] ?? [];

  Map<State, OnEntry> get stateEntry;
  Map<State, OnExit> get stateExit;

  /// Entry actions for current state
  OnEntry get currentStateEntry => stateEntry[currentState.state] ?? OnEntry();

  /// Exit actions for current state
  OnExit get currentStateExit => stateExit[currentState.state] ?? OnExit();

  /// Services for each states
  Map<State, List<Services>> get stateServices;

  /// Services to execute for current state
  List<Services> get currentStateServices =>
      stateServices[currentState.state] ?? [];

  /// According to the statecharts.dev, the deepest child should handle the event.
  EventResult handleEvent<Data>(
    String event,
    int eventId, [
    Data? data,
    Duration after = const Duration(milliseconds: 0),
  ]) {
    /// Not started yet or done. Do nothing.
    if (!_started || done) {
      return EventResult.notHandled();
    }

    /// The deepest child should handle the event.
    final result = child?.handleEvent(event, eventId, data, after) ??
        EventResult.notHandled();

    if (result.handled) {
      /// If one of the children handled this event, then return
      return result;
    }

    /// Find the beat related to specific state.
    var beats = normalBeats.where((beat) => beat.event == event);

    if (beats.isEmpty) {
      /// If specified beat is not available,
      /// then find station's root beat.
      beats = stationBeats.where((beat) => beat.event == event);
    }

    /// If this station can't handle this event, return
    if (beats.isEmpty) {
      return EventResult.notHandled();
    }

    final eventData = EventData(event: event, data: data);

    if (after.inMicroseconds > 0) {
      /// 0-1. if this is a delayed event, queue it and return
      addDelayed(
        () {
          /// Only run the first matching beat with the same event
          for (final beat in beats) {
            if (_passGuards(beat, eventData)) {
              handleBeat(
                beat.to,
                eventData,
                beat.actions,
              );
              return;
            }
          }
        },
        after,
        eventId,
      );
    } else {
      /// 0-2. else: immediately run the first matching beat with the same event
      for (final beat in beats) {
        if (_passGuards(beat, eventData)) {
          handleBeat(beat.to, eventData, beat.actions);
          break;
        }
      }
    }

    _eventHistory.add(eventData);
    return EventResult.handled();
  }

  /// Handle transitions
  /// **The beat's guards and delays should be checked before.**
  /// 0. clear delayed/guarded events
  /// 1. Execute this state's exit actions
  /// 2. Execute this transition's actions
  /// 3. Set next state and do afterwork
  /// 4. Execute this state's entry actions
  /// 5. Check eventless events in [BeatMachine]
  /// 6. Queue eventless events
  handleBeat(Enum nextState, EventData eventData, [List actions = const []]) {
    /// 0. clear delayed/guarded events
    clearDelayed();
    guardedEventlesses.clear();

    /// 1. Execute this state's exit actions
    _executeActions(currentStateExit.actions, currentState, eventData);

    /// 2-1. Execute this transition's actions
    _executeActions(actions, currentState, eventData);

    /// 2-2. Set state
    if (nextState is State) {
      handleTransition(nextState, eventData);
    } else {
      /// Propagate to machine and return
      final station = machine.stationOf(nextState.runtimeType);
      if (station == null) {
        return;
      }

      /// 1. Stop this stationn
      stop();

      /// 2. Start remote station if it's not
      if (!station._started) {
        station.start(state: nextState, eventData: eventData);
      } else {
        /// 3. else. Set remote station's state
        station.handleBeat(nextState, eventData);
      }
    }
  }

  handleTransition(State nextState, EventData eventData) {
    /// 3. Set next state and do afterwork
    setEnumState(nextState);

    /// 4. Execute this state's entry actions
    _executeActions(currentStateEntry.actions, currentState, eventData);

    /// 4-1. Check queued eventless events in [BeatMachine]
    machine.checkGuardedEventless();

    /// 4-2. check guarded eventless first
    final guarded = eventlessBeats.where(
      (beat) => !_isDelayedBeat(beat) && beat.conditions.isNotEmpty,
    );

    guardedEventlesses.addAll(guarded);

    final handled = checkGuardedEventless();

    if (handled) {
      return;
    }

    /// 4-3. if: Check imediate eventless events in this [BeatStation]
    /// - no delay
    /// - no gaurds
    final imediates = eventlessBeats.where(
      (beat) => !_isDelayedBeat(beat) && beat.conditions.isEmpty,
    );

    /// only the first eventless event is handled
    if (imediates.isNotEmpty) {
      final beat = imediates.first;
      handleBeat(beat.to, eventData, beat.actions);
      return;
    }

    /// 4-4. else: Queue delayed
    final delayed = eventlessBeats.where(
      (beat) => _isDelayedBeat(beat),
    );

    for (final d in delayed) {
      final delay = execActionMethod<Duration>(
            d.after,
            currentState,
            eventData,
          ) ??
          Duration.zero;
      addDelayed(
        () {
          if (_passGuards(d, eventData)) {
            handleBeat(
              d.to,
              eventData,
              d.actions,
            );
            return;
          }
        },
        delay,
      );
    }
  }

  /// Execute services for the current state
  executeServices() {}

  /// Helper method to handle actions
  _executeActions(
    List<dynamic> actions,
    BeatState<State, Context> state,
    EventData eventData,
  ) {
    for (final action in actions) {
      ActionHandler(
        action: action,
        state: state,
        event: eventData,
        station: this,
      ).handleAction();
    }
  }

  bool _passGuards(Beat beat, EventData event) {
    if (beat.conditions.isEmpty) {
      return true;
    }
    return beat.conditions.fold<bool>(
      false,
      (result, e) =>
          result ||
          (execActionMethod<bool>(
                e,
                currentState,
                event,
              ) ??
              false),
    );
  }
}
