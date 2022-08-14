import 'package:beat_config/beat_config.dart';

String firstMatchingList(String source) {
  int bracketCount = 0;
  int start = 0;
  for (var i = 0; i < source.length; ++i) {
    final char = source[i];
    if (char == '[') {
      if (bracketCount == 0) {
        start = i;
      }
      bracketCount++;
    } else if (char == ']') {
      bracketCount--;
    }
    if (char == ']' && bracketCount == 0) {
      return source.substring(start, i + 1);
    }
  }
  return '';
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

String toBeatAnnotationVariableName(
  String fromBase,
  String fromField,
  String event,
  String toBase,
  String toField,
) =>
    '_${toDartFieldCase(event)}From${toBeginningOfSentenceCase(fromBase)}${toBeginningOfSentenceCase(fromField)}To${toBeginningOfSentenceCase(toBase)}${toBeginningOfSentenceCase(toField)}';

String toBeatAnnotationVariableDeclaration(
  BeatConfig config,
) =>
    '''const ${toBeatAnnotationVariableName(config.fromBase, config.fromField, config.event, config.toBase, config.toField)} = 
    ${config.eventless ? 'EventlessBeat' : 'Beat'}(
      ${config.eventless ? '' : "event: '${config.event}'"},
      to: ${config.toBase}.${config.toField},
      actions: ${config.actions ?? const []},
      conditions: ${config.conditions ?? const []},
      eventDataType: ${config.eventDataType ?? dynamic},
      ${config.eventless ? 'after: ${config.after},' : ''}
    );''';

String toInvokeVariableName(InvokeConfig config) =>
    '_invokeOn${toBeginningOfSentenceCase(config.stateBase)}${toBeginningOfSentenceCase(config.stateField)}';
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

String toStateMatcher(
  String baseName,
  String fieldName,
  bool isRoot,
) =>
    'is${isRoot ? '' : baseName}${toBeginningOfSentenceCase(fieldName)}\$';

String toActionExecutorMethodName(String event) =>
    '_exec${toBeginningOfSentenceCase(event)}Actions';

String toSubstationFieldName(String name) => '${toDartFieldCase(name)}\$';

String toTransitionFieldName(String stateFrom) =>
    'on${toBeginningOfSentenceCase(stateFrom)}\$';
