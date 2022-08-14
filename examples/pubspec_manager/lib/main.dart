import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/args/args.dart';

void main(List<String> mainArgs) {
  args.addAll(mainArgs);
  print(mainArgs);
  runApp(const PubspecManager());
}
