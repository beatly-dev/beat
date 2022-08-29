import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../generator/utils/string.dart';

class BeatConsumerGenerator {
  final ClassElement baseEnum;
  final StationDataStore store;

  BeatConsumerGenerator(this.baseEnum, this.store);
  String get name => baseEnum.name;
  String get ref => '${name}Ref';
  String get consumer => '${name}Consumer';
  String get consumerWidget => '${name}ConsumerWidget';
  String get statefulConsumerWidget => '${name}StatefulConsumerWidget';
  String get consumerState => '${name}DefaultConsumerState';
  String get statefulConsumerState => '${name}StatefulConsumerState';
  String get statefulConsumerElement => '${name}StatefulElement';
  String get provider => '${name}Provider';
  String get machine => toMachineName(name);
  BeatStationNode? get station => store.stations[name];
  ParallelStationNode? get parallel => store.parallels[name];
  String get contextType => station?.contextType ?? 'dynamic';
  bool get withFlutter =>
      station?.withFlutter ?? parallel?.withFlutter ?? false;

  @override
  String toString() {
    if (!withFlutter) {
      return '';
    }
    return '''
abstract class $ref{
  $machine get machine;
  
  T read<T>(T Function($machine station) reader);
  T select<T>(T Function($machine station) selector);
}

class $consumer extends $consumerWidget {
  const $consumer({
    required this.builder,
    super.placeHolder,
    super.key,
  });

  final Widget Function(BuildContext context, $ref) builder;

  @override
  Widget build(BuildContext context, $ref ref) {
    return builder(context, ref);
  }
}

abstract class $consumerWidget extends $statefulConsumerWidget {
  const $consumerWidget({
    Key? key,
    this.placeHolder = const SizedBox.shrink(),
  }) : super(key: key);

  Widget build(BuildContext context, $ref ref);
  final Widget placeHolder;

  @override
  // ignore: library_private_types_in_public_api
  $consumerState createState() => $consumerState();
}

class $consumerState
    extends $statefulConsumerState<$consumerWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, ref);
  }
}

abstract class $statefulConsumerWidget extends StatefulWidget {
  const $statefulConsumerWidget({Key? key}) : super(key: key);

  @override
  $statefulConsumerState createState();

  @override
  StatefulElement createElement() => $statefulConsumerElement(this);
}

abstract class $statefulConsumerState<
    T extends $statefulConsumerWidget> extends State<T> {
  $ref get ref => context as $ref;
}

class $statefulConsumerElement extends StatefulElement
    implements $ref {
  $statefulConsumerElement(super.widget);

  int _count = 0;

  /// Get the machine and listen to all type of changes,
  /// including enum state changes, context changes, and the machine itself.
  @override
  $machine get machine =>
      ${name}ProviderScope.of(this, dependency: 'machine').machine;

  /// Read the machine or its values but not listening to it. 
  @override
  T read<T>(T Function($machine machine) selector) {
    final $machine machine = ${name}ProviderScope.of(this, dependency: '_readonly_').machine;
    final result = selector(machine);
    return result;
  }

  /// Precisely listen to the machine or its values.
  /// `ref.machine` will watch everything, 
  /// `ref.select((machine) => station.currentState.context)` will watch only the context's changes.
  /// `ref.select((machine) => station.currentState.context.myField)` will watch only the context's myField changes.
  @override
  T select<T>(T Function($machine machine) selector) {
    final id = '\$hashCode.\${_count++}';
    return ${name}ProviderScope.of(this, dependency: id).watch(id, selector);
  }
}
''';
  }
}
