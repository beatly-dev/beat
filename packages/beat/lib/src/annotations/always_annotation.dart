import 'beat_annotation.dart';

class Always {
  const Always({this.beats = const []});
  final List<AlwaysBeat> beats;
}

class AlwaysBeat extends Beat {
  const AlwaysBeat({
    required super.to,
    super.actions,
    super.eventDataType,
    super.conditions,
  }) : super(event: '');
}
