import '../models/invoke_config.dart';

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
String toBeatTransitionBaseClassName(String baseName) =>
    'On${toBeginningOfSentenceCase(baseName)}TransitionsInterface';
String toBeatTransitionRealClassName(String baseName) =>
    'On${toBeginningOfSentenceCase(baseName)}Transitions';
String toBeatTransitionDummyClassName(String baseName) =>
    'On${toBeginningOfSentenceCase(baseName)}TransitionsDummy';
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

String toBeatActionVariableName(String from, String event, String to) =>
    '_${toDartFieldCase(event)}From${toBeginningOfSentenceCase(from)}To${toBeginningOfSentenceCase(to)}';

String toBeatActionVariableDeclaration(
  String from,
  String event,
  String to,
  String source,
) =>
    'const ${toBeatActionVariableName(from, event, to)} = $source;';

String toInvokeVariableName(InvokeConfig config) =>
    '_invokeOn${toBeginningOfSentenceCase('${config.stateName}\$${config.on}')}';
String toInvokeVariableDeclaration(InvokeConfig config) =>
    'const ${toInvokeVariableName(config)} = ${config.source};';

String toBeatSenderClassName(String base) =>
    '${toBeginningOfSentenceCase(base)}BeatSender';
