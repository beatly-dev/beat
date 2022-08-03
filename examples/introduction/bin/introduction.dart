enum Hello { world }

void main(List<String> arguments) {
  final wo = Worlder(Hello.world);
  print(wo.value);
}

class Worlder<T extends Enum> {
  final T value;

  Worlder(this.value);
}
