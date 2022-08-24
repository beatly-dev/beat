import '../classes/beat_state.dart';
import '../classes/event_data.dart';
import '../utils/function.dart';

///
class Raise {
  const Raise(this.producer);
  final dynamic producer;

  RaiseInfo? produce(BeatState state, EventData event) {
    final info = execActionMethod<RaiseInfo>(producer, state, event);
    return info;
  }
}

class RaiseInfo<Data> {
  const RaiseInfo(
    this.event, {
    this.data,
  });
  final String event;
  final Data? data;
}
