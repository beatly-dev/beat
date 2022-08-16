import 'dart:io';

import 'package:beat/beat.dart';
import 'package:pubspec2/pubspec2.dart';

part 'pubspec.beat.dart';

@BeatStation(contextType: PubspecInfoData)
@loadPubspecBeat
enum PubspecInfo {
  @invokeLoader
  loading,
  loaded,
  error,
}

const loadPubspecBeat = Beat(event: 'load', to: PubspecInfo.loading);

const invokeLoader = Invokes([
  InvokeFuture(
    loadPubspecInfoService,
    onDone: AfterInvoke(
      to: PubspecInfo.loaded,
      actions: [AssignAction(assignPubspecAction)],
    ),
    onError: AfterInvoke(
      to: PubspecInfo.error,
    ),
  ),
]);

Future<PubSpec?> loadPubspecInfoService(BeatState state, __) async {
  final data = state.context;

  /// TODO
  /// if beat support guarded transition, we can use this to avoid type and null check
  if (data is! PubspecInfoData) {
    return null;
  }
  final projectPath = data.projectPath;
  final pubspec = await PubSpec.load(Directory(projectPath));
  return pubspec;
}

PubspecInfoData assignPubspecAction(BeatState state, EventData event) {
  final data = event.data;

  /// TODO
  /// if beat support guarded transition, we can use this to avoid type and null check
  if (data is! PubSpec) {
    return state.context;
  }
  return PubspecInfoData(
    projectPath: state.context.projectPath,
    pubspec: data,
  );
}

class PubspecInfoData {
  final PubSpec? pubspec;
  final String projectPath;

  PubspecInfoData({
    this.pubspec,
    required this.projectPath,
  });
}
