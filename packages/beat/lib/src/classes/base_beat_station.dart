import 'dart:async';

import 'package:meta/meta.dart';

abstract class BeatStationBase {
  final _delayed = <Timer>{};

  @protected
  addDelayed(Duration duration, Function() callback) {
    _delayed.add(Timer(duration, callback));
  }

  @protected
  clearDelayed() {
    for (final timer in _delayed) {
      timer.cancel();
    }
    _delayed.clear();
  }
}
