abstract class BeatState<Context> {
  Enum get state;
  Context get context;
  const BeatState();

  bool get hasSubstate;

  BeatState? of(Type enumType) => null;
}
