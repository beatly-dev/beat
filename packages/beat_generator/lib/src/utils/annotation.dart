import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:beat/beat.dart';
import 'package:beat_generator/src/models/beat_config.dart';
import 'package:source_gen/source_gen.dart';

import 'field.dart';

Map<String, List<BeatConfig>> mapBeatAnnotations(List<FieldElement> fields) {
  return fields.fold(<String, List<BeatConfig>>{}, (beats, field) {
    final annotations = beatAnnotations(field);

    for (final annotation in annotations) {
      final from = field.name;
      final actionField = annotation.read('event');
      final toField = annotation.read('to');
      String action = getFieldValueAsString(actionField);
      String to = getFieldValueAsString(toField);

      if (toField.isLiteral) {}
      final config = BeatConfig(
        from: from,
        action: action,
        to: to,
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

const _beatChecker = TypeChecker.fromRuntime(Beat);

List<DartObject> _beatAnnotations(FieldElement element) =>
    _beatChecker.annotationsOf(element, throwOnUnresolved: false).toList();

List<ConstantReader> beatAnnotations(FieldElement element) =>
    _beatAnnotations(element).map((e) => ConstantReader(e)).toList();
