import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'src/app.dart';
import 'src/args/args.dart';

void main(List<String> mainArgs) async {
  args.addAll(mainArgs);
  await Isar.initializeIsarCore(download: true);
  runApp(
    PubspecManager(),
  );
}
