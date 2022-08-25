/// A data passed to action and service.
/// `event` holds an event name and `data` holds a custom user data.
class EventData<Data> {
  const EventData({
    required this.event,
    this.data,
  });

  final String event;
  final Data? data;

  @override
  String toString() => "{'event': '$event', 'data': ${data.toString()}}";
}
