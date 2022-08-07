abstract class BaseBeatState<Context> {
  final Enum state;
  final Context context;
  const BaseBeatState(this.state, this.context);
}
