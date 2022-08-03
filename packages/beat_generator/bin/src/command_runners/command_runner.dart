// FROM build_runner
// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.build_runner file.

import 'dart:convert';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:build_runner/src/entrypoint/base_command.dart';
import 'package:build_runner/src/entrypoint/base_command.dart' show lineLength;
import 'package:build_runner_core/build_runner_core.dart';

import '../commands/build.dart';
import '../commands/watch.dart';

/// Unified command runner for all build_runner commands.
class BuildBeatCommandRunner extends CommandRunner<int> {
  @override
  final argParser = ArgParser(usageLineLength: lineLength);

  final List<BuilderApplication> builderApplications;

  final PackageGraph packageGraph;

  BuildBeatCommandRunner(
    List<BuilderApplication> builderApplications,
    this.packageGraph,
  )   : builderApplications = List.unmodifiable(builderApplications),
        super('beat_generator', 'Generate state management code for Beat.') {
    addCommand(BuildBeatCommand());
    addCommand(WatchBeatCommand());
  }

  // CommandRunner._usageWithoutDescription is private – this is a reasonable
  // facsimile.
  /// Returns [usage] with [description] removed from the beginning.
  String get usageWithoutDescription => LineSplitter.split(usage)
      .skipWhile((line) => line == description || line.isEmpty)
      .join('\n');
}
