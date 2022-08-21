import 'package:beat/beat.dart';
import 'package:flutter/material.dart';

/// Parameters
/// - firstState
/// - initialContext
/// - actions
/// - conditions
/// - invokes
/// - delays
abstract class BeatStationScope<Context> extends StatefulWidget {
  const BeatStationScope({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;
  @protected
  void beforeStart(BeatStationBase<Context> station) {}
  @protected
  void beforeDispose(BeatStationBase<Context> station) {}

  bool get autoStart;
  BeatStationBase<Context> get station;
}

abstract class BeatStationScopeState<Scope extends BeatStationScope>
    extends State<Scope> {
  @override
  @mustCallSuper
  void initState() {
    super.initState();
    widget.beforeStart(widget.station);
    if (widget.autoStart) {
      widget.station.start();
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    widget.beforeDispose(widget.station);
    widget.station.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(
    covariant Scope oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.station != widget.station) {
      oldWidget.station.stop();
      widget.station.start();
    }
  }
}

abstract class BeatStationProviderScope extends InheritedModel<Object> {
  const BeatStationProviderScope({
    required super.child,
    super.key,
  });
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
}
