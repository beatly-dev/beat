import '../../beat.dart';

T? execActionMethod<T>(dynamic method, BeatState state, EventData event) {
  if (method is T Function(BeatState, EventData)) {
    return method(state, event);
  }
  if (method is T Function(BeatState)) {
    return method(state);
  }
  if (method is T Function(EventData)) {
    return method(event);
  }
  if (method is T Function()) {
    return method();
  }
  if (method is T) {
    return method;
  }
  return null;
}
