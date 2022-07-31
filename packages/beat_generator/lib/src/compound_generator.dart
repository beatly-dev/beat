import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class CompoundGenerator extends Generator {
  int counter = 0;
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    counter++;
    print("Compound generator $counter");
    print(hashCode);
    return '';
  }
}
