import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_generator/src/models/beat_config.dart';
import 'package:source_gen/source_gen.dart';

import 'field.dart';

Map<String, List<BeatConfig<C>>> mapBeatAnnotations<C>(
    String stateName, List<Element> fields) {
  return fields.fold(<String, List<BeatConfig<C>>>{}, (beats, field) {
    final annotations = beatAnnotations(field);

    for (final annotation in annotations) {
      final from = field.name!;
      final actionField = annotation.read('event');
      final toField = annotation.read('to');
      final assignField = annotation.peek('assign');

      String action = getFieldValueAsString(actionField);
      String to = getFieldValueAsString(toField);
      String assign = getFunctionName(assignField);

      final config = BeatConfig<C>(
        from: from,
        event: action,
        to: to,
        assign: assign,
      );
      if (beats.containsKey(from)) {
        beats[from]!.add(config);
      } else {
        beats[from] = [config];
      }
    }

    return beats;
  });
}

List<BeatConfig<C>> mapCommonBeatAnnotations<C>(
    String stateName, List<Element> fields) {
  return fields.fold(<BeatConfig<C>>[], (beats, field) {
    final annotations = beatAnnotations(field);

    for (final annotation in annotations) {
      final from = '';
      final actionField = annotation.read('event');
      final toField = annotation.read('to');
      final assignField = annotation.peek('assign');

      String action = getFieldValueAsString(actionField);
      String to = getFieldValueAsString(toField);
      String assign = getFunctionName(assignField);

      final config = BeatConfig<C>(
        from: from,
        event: action,
        to: to,
        assign: assign,
      );
      beats.add(config);
    }

    return beats;
  });
}

const _beatChecker = TypeChecker.fromRuntime(Beat);

List<DartObject> _beatAnnotations(Element element) =>
    _beatChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> beatAnnotations(Element element) =>
    _beatAnnotations(element).map((e) => ConstantReader(e)).toList();
