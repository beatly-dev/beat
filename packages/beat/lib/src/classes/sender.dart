import 'beat_station.dart';

abstract class Sender<T extends BeatStation> {
  const Sender(this._station);
  final T _station;
  call<Data>(String event, {Data? data, Duration after = const Duration()}) =>
      _station.handleEvent(event, data, after);
}
