// FROM build_runner
// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.build_runner file.

import 'dart:async';

import 'package:build/experiments.dart';
import 'package:build_runner/src/entrypoint/base_command.dart';
import 'package:build_runner/src/entrypoint/options.dart';
import 'package:build_runner/src/generate/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:io/io.dart';

/// A command that does a single build and then exits.
class BuildBeatCommand extends BuildRunnerCommand {
  @override
  String get invocation => '${super.invocation} [directories]';

  @override
  String get name => 'build';

  @override
  String get description =>
      'Performs a single build on the specified targets and then exits.';

  @override
  Future<int> run() {
    var options = readOptions();
    return withEnabledExperiments(
      () => _run(options),
      options.enableExperiments,
    );
  }

  Future<int> _run(SharedOptions options) async {
    var result = await build(
      builderApplications,
      buildFilters: options.buildFilters,
      deleteFilesByDefault: options.deleteFilesByDefault,
      enableLowResourcesMode: options.enableLowResourcesMode,
      configKey: options.configKey,
      buildDirs: options.buildDirs,
      outputSymlinksOnly: options.outputSymlinksOnly,
      packageGraph: packageGraph,
      verbose: options.verbose,
      builderConfigOverrides: options.builderConfigOverrides,
      isReleaseBuild: options.isReleaseBuild,
      trackPerformance: options.trackPerformance,
      skipBuildScriptCheck: options.skipBuildScriptCheck,
      logPerformanceDir: options.logPerformanceDir,
    );
    if (result.status == BuildStatus.success) {
      return ExitCode.success.code;
    } else {
      return result.failureType?.exitCode ?? 1;
    }
  }
}
