import 'package:beat/beat.dart';
import 'package:flutter/material.dart';

/// Parameters
/// - firstState
/// - initialContext
/// - actions
/// - conditions
/// - invokes
/// - delays
abstract class BeatStationScope<M extends BeatMachine, Context>
    extends StatefulWidget {
  const BeatStationScope({
    Key? key,
    required this.child,
    this.initialContext,
  }) : super(key: key);

  final Widget child;
  final Context? initialContext;
  beforeMachineStart(BeatMachine machine);
  beforeMachineStop(BeatMachine machine);

  M get machine;
}

abstract class BeatStationScopeState<Scope extends BeatStationScope>
    extends State<Scope> {
  @override
  @mustCallSuper
  void initState() {
    super.initState();
    widget.beforeMachineStart(widget.machine);
    widget.machine.start(context: widget.initialContext);
  }

  @override
  @mustCallSuper
  void dispose() {
    widget.beforeMachineStop(widget.machine);
    widget.machine.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(
    covariant Scope oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.machine != widget.machine) {
      oldWidget.machine.stop();
      widget.machine.start();
    }
  }
}

abstract class BeatStationProviderScope<M extends BeatMachine>
    extends InheritedModel<Object> {
  BeatStationProviderScope({
    required super.child,
    required this.machine,
    super.key,
  });
  final M machine;
  final Map<String, dynamic> _partOfMaps = {};
  final Map<String, dynamic> _partOfSelectorMaps = {};

  static Provider of<Provider extends InheritedModel<Object>>(
    BuildContext context, {
    Object? dependency,
  }) {
    final provider = InheritedModel.inheritFrom<Provider>(
      context,
      aspect: dependency,
    );
    assert(
      provider != null,
      'You should wrap your widget with a {YourState}Provider',
    );
    return provider!;
  }

  T watch<T>(String key, T Function(M machine) selector) {
    final value = selector(machine);
    _partOfMaps.addAll({key: value});
    _partOfSelectorMaps.addAll({key: selector});
    return value;
  }

  @override
  bool updateShouldNotify(
    covariant BeatStationProviderScope oldWidget,
  ) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant BeatStationProviderScope oldWidget,
    Set<Object> dependencies,
  ) {
    if (machine != oldWidget.machine) {
      return true;
    }

    final watched = dependencies.where((element) => element != '_readonly_');

    if (watched.isEmpty) {
      return false;
    }

    // if it depdens on station, every changes should notify
    if (watched.any((d) => d == 'machine')) {
      return true;
    }

    final selected = watched.where((d) => d is String && d != 'machine');

    final changed = selected.any((d) {
      if (d is! String) {
        return false;
      }
      final oldValue = oldWidget._partOfMaps[d];
      final newValue = oldWidget._partOfSelectorMaps[d]?.call(machine);

      /// To ensure that the non-rerendered widget will be notified
      _partOfMaps[d] = newValue;
      _partOfSelectorMaps[d] = oldWidget._partOfSelectorMaps[d];
      return oldValue != newValue;
    });

    return changed;
  }
}
