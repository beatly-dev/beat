class EventResult {
  final bool handled;
  const EventResult.notHandled() : handled = false;
  const EventResult.handled() : handled = true;
}
