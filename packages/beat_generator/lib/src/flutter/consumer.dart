import 'package:analyzer/dart/element/element.dart';

import '../models/state.dart';
import '../resources/beat_tree_resource.dart';
import '../utils/context.dart';
import '../utils/string.dart';

class BeatConsumerGenerator {
  final ClassElement baseEnum;
  final BeatTreeSharedResource beatTree;

  BeatConsumerGenerator(this.baseEnum, this.beatTree);
  late final node = beatTree.getNode(baseEnum.name);
  String get firstField =>
      baseEnum.fields.where((element) => element.isEnumConstant).first.name;
  String get enumName => baseEnum.name;
  String get className => '${enumName}Provider';
  String get stationName => toBeatStationClassName(enumName);
  String get beatName => toBeatStateClassName(enumName);
  String get senderName => toBeatSenderClassName(enumName);
  String get contextType => toContextType(node.info.contextType);
  ClassElement? get contextClass =>
      baseEnum.library.getClass(node.info.contextType);

  String contextTypeFields() {
    final context = contextClass;
    if (context == null) {
      return '';
    }
    final fields = context.fields;

    return fields
        .map(
          (field) =>
              '''${field.type.getDisplayString(withNullability: true).replaceAll(RegExp(r'[*?]'), '')}? get \$\$${field.name};''',
        )
        .join();
  }

  String contextFieldGetter() {
    final context = contextClass;
    if (context == null) {
      return '';
    }
    final fields = context.fields;

    return fields
        .map(
          (field) => '''
@override
${field.type.getDisplayString(withNullability: true).replaceAll(RegExp(r'[*?]'), '')}? get \$\$${field.name} =>
              ${enumName}ProviderScope.of(this, dependency: 'context.${field.name}')
          .station
          .currentState
          .context?.${field.name};
                ''',
        )
        .join();
  }

  Future<String> stateMatcherFields() async {
    final nodes = await beatTree.getRelatedStations(enumName);
    final states = nodes.map((node) {
      final baseEnumName = node.info.baseEnumName;
      return node.info.states.map((state) => StateWrapper(baseEnumName, state));
    }).expand((states) => states);

    final matchers = states.map((state) {
      return toStateMatcher(
        state.baseName,
        state.fieldName,
        state.baseName == enumName,
      );
    });

    /// TODO:
    /// If a user asks for a parallel state => not yet supported
    return matchers.map((matcher) {
      return '''
bool get $matcher;
      ''';
    }).join();
  }

  Future<String> stateMatcherGetter() async {
    final nodes = await beatTree.getRelatedStations(enumName);
    final states = nodes.map((node) {
      final baseEnumName = node.info.baseEnumName;
      return node.info.states.map((state) => StateWrapper(baseEnumName, state));
    }).expand((states) => states);

    final matchers = states.map((state) {
      return toStateMatcher(
        state.baseName,
        state.fieldName,
        state.baseName == enumName,
      );
    });

    /// TODO:
    /// If a user asks for a parallel state => not yet supported
    return matchers.map((matcher) {
      return '''
  @override
  bool get $matcher => CounterProviderScope.of(this, dependency: r'$matcher')
      .station
      .currentState
      .$matcher;
      ''';
    }).join();
  }

  Future<String> toConsumer() async {
    if (!node.info.withFlutter) {
      return '';
    }
    return '''
abstract class ${enumName}Ref{
  $stationName get station;
  $beatName get currentState;
  $enumName get enumState;
  $contextType get context;
  ${contextTypeFields()}
  ${await stateMatcherFields()}
  ${toBeatSenderClassName(enumName)} get send;
}

class ${enumName}Consumer extends ${enumName}ConsumerWidget {
  const ${enumName}Consumer({
    this.child,
    required this.builder,
    super.key,
  });

  final Widget? child;

  final Widget Function(BuildContext, ${enumName}Ref, Widget?) builder;

  @override
  Widget build(BuildContext context, ${enumName}Ref ref) {
    return builder(context, ref, child);
  }
}

abstract class ${enumName}ConsumerWidget extends Stateful${enumName}ConsumerWidget {
  const ${enumName}ConsumerWidget({Key? key}) : super(key: key);

  Widget build(BuildContext context, ${enumName}Ref ref);

  @override
  // ignore: library_private_types_in_public_api
  _${enumName}ConsumerState createState() => _${enumName}ConsumerState();
}

class _${enumName}ConsumerState
    extends ${enumName}ConsumerWidgetState<${enumName}ConsumerWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, ref);
  }
}

abstract class Stateful${enumName}ConsumerWidget extends StatefulWidget {
  const Stateful${enumName}ConsumerWidget({Key? key}) : super(key: key);

  @override
  ${enumName}ConsumerWidgetState createState();

  @override
  StatefulElement createElement() => Stateful${enumName}ConsumerElement(this);
}

abstract class ${enumName}ConsumerWidgetState<
    T extends Stateful${enumName}ConsumerWidget> extends State<T> {
  ${enumName}Ref get ref => context as ${enumName}Ref;
}

class Stateful${enumName}ConsumerElement extends StatefulElement
    implements ${enumName}Ref {
  Stateful${enumName}ConsumerElement(super.widget);

  @override
  $stationName get station =>
      ${enumName}ProviderScope.of(this, dependency: 'station').station;

  @override
  $beatName get currentState =>
      ${enumName}ProviderScope.of(this, dependency: 'currentState')
          .station
          .currentState;

  @override
  $enumName get enumState =>
      ${enumName}ProviderScope.of(this, dependency: 'enumState')
          .station
          .currentState
          .state;

  @override
  $contextType get context => ${enumName}ProviderScope.of(this, dependency: 'context')
      .station
      .currentState
      .context;

  @override
  ${toBeatSenderClassName(enumName)} get send => station.send;

  ${contextFieldGetter()}

  ${await stateMatcherGetter()}
}

''';
  }
}
