import '../classes/beat_state.dart';
import '../classes/event_data.dart';
import '../utils/function.dart';

///
class Send {
  const Send(this.producer);
  final dynamic producer;

  SendInfo? produce(BeatState state, EventData event) {
    final info = execActionMethod<SendInfo>(producer, state, event);
    return info;
  }
}

class SendInfo<Data> {
  const SendInfo(
    this.event, {
    this.to,
    this.data,
    this.after = const Duration(),
  });
  final String event;
  final Data? data;
  final Type? to;
  final Duration after;
}
