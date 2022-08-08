import 'package:beat_config/beat_config.dart';

String firstMatchingList(String source) {
  final buffer = StringBuffer();
  int bracketCount = 0;
  for (var i = 0; i < source.length; ++i) {
    final char = source[i];
    if (char == '[') {
      bracketCount++;
    } else if (char == ']') {
      bracketCount--;
    }
    buffer.write(char);
    if (char == ']' && bracketCount == 0) {
      break;
    }
  }
  return buffer.toString();
}

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

/// Beat transition related
String toBeatTransitionBaseClassName(String base, String state) =>
    'On$base${toBeginningOfSentenceCase(state)}TransitionsInterface';
String toBeatTransitionRealClassName(String base, String state) =>
    'On$base${toBeginningOfSentenceCase(state)}Transitions';
String toBeatTransitionDummyClassName(String base, String state) =>
    'On$base${toBeginningOfSentenceCase(state)}TransitionsDummy';

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

String toBeatVariableName(
  String fromBase,
  String fromField,
  String event,
  String toBase,
  String toField,
) =>
    '_${toDartFieldCase(event)}From${toBeginningOfSentenceCase(fromBase)}${toBeginningOfSentenceCase(fromField)}To${toBeginningOfSentenceCase(toBase)}${toBeginningOfSentenceCase(toField)}';

String toBeatVariableDeclaration(
  String fromBase,
  String fromField,
  String event,
  String toBase,
  String toField,
  String? actions,
  String? conditions,
  String? eventDataType,
) =>
    '''const ${toBeatVariableName(fromBase, fromField, event, toBase, toField)} = Beat(
      event: '$event',
      to: $toBase.$toField,
      actions: ${actions ?? const []},
      conditions: ${conditions ?? const []},
      eventDataType: ${eventDataType ?? dynamic},
    );''';

String toInvokeVariableName(InvokeConfig config) =>
    '_invokeOn${toBeginningOfSentenceCase('${config.stateBase}${config.stateField}')}';
String toInvokeVariableDeclaration(InvokeConfig config) =>
    'const ${toInvokeVariableName(config)} = ${config.source};';

String toBeatSenderClassName(String base) =>
    '${toBeginningOfSentenceCase(base)}BeatSender';

String toBeatSenderBeatStationFieldName(String base) =>
    '_${toDartFieldCase(base)}beatStation';

String toBeatSenderInitializerMethodName(String base) =>
    '_initialize${toBeatSenderClassName(base)}';

String toBeatSenderInitializerArgumentName(String base) =>
    '${toDartFieldCase(base)}beatStation';

String toCompoundFieldName(String base) => '${toDartFieldCase(base)}Compound';

String toStateMatcher(String baseName, String fieldName) =>
    'is$baseName${toBeginningOfSentenceCase(fieldName)}\$';
