String toBeginningOfSentenceCase(String str) {
  if (str.isEmpty) return str;
  return '${str[0].toUpperCase()}${str.substring(1)}';
}

String toDartFieldCase(String str) {
  if (str.isEmpty) return str;
  return '${str[0].toLowerCase()}${str.substring(1)}';
}

String toBaseBeatStateClassName(String name) =>
    '${toBeginningOfSentenceCase(name)}BeatState';
String toBeatTransitionClassName(String baseName) =>
    'On${toBeginningOfSentenceCase(baseName)}BeatState';
String toExecMethodName(String baseName) =>
    'execWhen${toBeginningOfSentenceCase(baseName)}';
String toMapMethodName(String baseName) =>
    'mapWhen${toBeginningOfSentenceCase(baseName)}';
String toCurrentStateCheckerGetterName(String name) =>
    'is${toBeginningOfSentenceCase(name)}';
String toAddListenerMethodName(String baseName) =>
    'addListenerOn${toBeginningOfSentenceCase(baseName)}';
String toRemoveListenerMethodName(String baseName) =>
    'removeListenerOn${toBeginningOfSentenceCase(baseName)}';
String toListenerFieldName(String baseName) =>
    '_listenersOn${toBeginningOfSentenceCase(baseName)}';

String toBeatStationClassName(String baseName) =>
    '${toBeginningOfSentenceCase(baseName)}BeatStation';

String toBeatStateClassName(String baseName) =>
    '${toBeginningOfSentenceCase(baseName)}BeatState';
