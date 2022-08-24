import 'package:meta/meta.dart';

import '../../beat.dart';
import '../utils/function.dart';

/// Define actions to change the context of the state
@sealed
class Assign {
  const Assign(this.producer);
  final dynamic producer;

  Context? compute<Context>(BeatState state, EventData event) =>
      execActionMethod<Context>(producer, state, event);
}
