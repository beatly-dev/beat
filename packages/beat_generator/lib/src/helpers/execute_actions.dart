class ActionExecutorBuilder {
  ActionExecutorBuilder({
    required this.isStation,
    required this.baseName,
    required this.contextType,
    required this.actionName,
    required this.eventData,
  });
  final bool isStation;
  final String baseName;
  final String contextType;
  final String actionName;
  final String eventData;
  final buffer = StringBuffer();

  String build() {
    final prefix = isStation ? '' : '_beatStation.';
    buffer.writeln(
      '''
    exec() =>
        $actionName.execute(${prefix}currentState.state, ${prefix}currentState.context, $eventData);
    if ($actionName is AssignAction) {
      ${prefix}_setContext(exec());
    } else if ($actionName is DefaultAction) {
      exec();
    } else if ($actionName is Function($baseName, $contextType, EventData)) {
      action(${prefix}currentState.state, ${prefix}currentState.context, $eventData);
    } else if ($actionName is Function($baseName, $contextType)) {
      action(${prefix}currentState.state, ${prefix}currentState.context);
    } else if ($actionName is Function($baseName)) {
      action(${prefix}currentState.state);
    } else if ($actionName is Function()) {
      action();
    }
    ''',
    );
    return buffer.toString();
  }
}
