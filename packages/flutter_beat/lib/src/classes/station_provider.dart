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
    this.beforeDispose,
    this.beforeStart,
  }) : super(key: key);

  final Widget child;
  final void Function(BeatStationBase<Context>)? beforeStart;
  final void Function(BeatStationBase<Context>)? beforeDispose;

  BeatStationBase<Context> get station;
}

abstract class BeatStationScopeState<Scope extends BeatStationScope>
    extends State<Scope> {
  @override
  @mustCallSuper
  void initState() {
    super.initState();
    widget.beforeStart?.call(widget.station);
    widget.station.start();
  }

  @override
  @mustCallSuper
  void dispose() {
    widget.beforeDispose?.call(widget.station);
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
      BuildContext context,
      {Object? dependency}) {
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
