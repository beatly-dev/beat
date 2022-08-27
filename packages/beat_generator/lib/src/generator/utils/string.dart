import '../../utils/string.dart';

String toStationName(String name) {
  return '${toBeginningOfSentenceCase(name)}Station';
}

String toAnnotationName(String name) {
  return '_${toDartFieldCase(name)}Annotation';
}

String toStateName(String name) {
  return '${toBeginningOfSentenceCase(name)}State';
}

String toParallelStationName(String name) => toStationName(name);

String toMachineName(String name) {
  return '${toBeginningOfSentenceCase(name)}Machine';
}

String toSenderName(String name) {
  return '\$${toBeginningOfSentenceCase(name)}Sender';
}

String toEventClassName(String name) =>
    '${toBeginningOfSentenceCase(name)}Events';

String toNestedEventClassName(String name) =>
    '_${toBeginningOfSentenceCase(name)}NestedEvents';
