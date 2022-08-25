import 'beat_station.dart';

abstract class Sender<T extends BeatStation> {
  const Sender(this._station);
  final T _station;
  call<Data>(String event, {Data? data, Duration after = const Duration()}) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final eventId = '$now-$event.${event.hashCode}';
    _station.handleEvent(event, eventId, data, after);
    return eventId;
  }
}
