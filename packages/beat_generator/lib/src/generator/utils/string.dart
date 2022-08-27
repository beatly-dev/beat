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

String toParallelStationName(String name) {
  return '${toBeginningOfSentenceCase(name)}ParallelStation';
}
