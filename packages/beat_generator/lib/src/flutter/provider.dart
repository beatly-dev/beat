import 'package:analyzer/dart/element/element.dart';
import 'package:beat_config/beat_config.dart';

import '../generator/utils/string.dart';

class BeatProviderGenerator {
  final ClassElement baseEnum;
  final StationDataStore store;

  BeatProviderGenerator(this.baseEnum, this.store);
  String get enumName => baseEnum.name;
  String get providerName => '${enumName}Provider';
  String get machineName => toMachineName(enumName);
  BeatStationNode? get station => store.stations[enumName];
  ParallelStationNode? get parallel => store.parallels[enumName];
  String get contextType => station?.contextType ?? 'dynamic';
  bool get withFlutter =>
      station?.withFlutter ?? parallel?.withFlutter ?? false;

  @override
  String toString() {
    if (!withFlutter) {
      return '';
    }
    return '''

class $providerName extends BeatStationScope<$machineName, ${contextType.replaceAll(r'?', '')}> {
  $providerName({
    required super.child,
    super.initialContext,
    this.beforeStart,
    this.beforeStop,
    super.key,
  });

  final Function($machineName machine)? beforeStart;
  final Function($machineName machine)? beforeStop;

  @override
  beforeMachineStart(covariant $machineName machine) => beforeStart?.call(machine);

  @override
  beforeMachineStop(covariant $machineName machine) => beforeStop?.call(machine);

  @override
  late final $machineName machine = $machineName();

  @override
  ${providerName}State createState() => ${providerName}State();
}

class ${providerName}State extends BeatStationScopeState<$providerName> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.machine.stream,
      builder: (context, snapshot) {
        return ${providerName}Scope(
          machine: widget.machine,
          child: widget.child,
        );
      },
    );
  }
}

class ${providerName}Scope extends BeatStationProviderScope<$machineName> {
  ${providerName}Scope({
    required super.child,
    required super.machine,
    super.key,
  });


  static ${providerName}Scope of(
    BuildContext context, {
    Object? dependency,
  }) {
    return BeatStationProviderScope.of<${providerName}Scope>(
      context,
      dependency: dependency,
    );
  }
}
''';
  }
}
