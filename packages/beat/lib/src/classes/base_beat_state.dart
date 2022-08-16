abstract class BeatState<State, Context> {
  final State state;
  final Context context;
  const BeatState(this.state, this.context)
      : assert(state is Enum || state is List<Enum>);

  bool get isParallelState => state is List;
  bool get isSingleState => state is Enum;
  bool get hasSubstate;

  List<Enum>? get parallelState => isParallelState ? state as List<Enum> : null;
  Enum? get singleState => isSingleState ? state as Enum : null;

  BeatState? of(Type enumType) => null;
}
