String createActionExecutor(
  String actionName,
  String eventData,
  bool isCommonEvent,
) {
  final prefix = isCommonEvent ? '' : '_station.';
  return '''
    exec() =>
        $actionName.execute(${prefix}currentState, $eventData);
    if ($actionName is AssignAction) {
      ${prefix}_setContext(exec());
    } else if ($actionName is DefaultAction) {
      exec();
    } else if ($actionName is Function(BeatState, EventData)) {
      action(${prefix}currentState, $eventData);
    } else if ($actionName is Function(BeatState)) {
      action(${prefix}currentState);
    } else if ($actionName is Function()) {
      action();
    }
    ''';
}
