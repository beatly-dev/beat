class EventData<Data> {
  const EventData({
    required this.event,
    this.data,
  });

  final String event;
  final Data? data;
}
