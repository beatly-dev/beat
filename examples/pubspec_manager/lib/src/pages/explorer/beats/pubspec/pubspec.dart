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
  /// TODO: Add conditions to service, after invoke, and actions.
  InvokeFuture(
    loadPubspecInfoService,
    onDone: AfterInvoke(
      to: PubspecInfo.loaded,
      actions: [assignPubspec],
    ),
    onError: AfterInvoke(
      to: PubspecInfo.error,
      actions: [logError],
    ),
  ),
]);

Future<PubSpec?> loadPubspecInfoService(BeatState state, __) async {
  final data = state.context;

  if (data is! PubspecInfoData) {
    throw 'Invalid context type: ${data.runtimeType}';
  }
  final projectPath = data.projectPath;
  final pubspec = await PubSpec.load(Directory(projectPath));
  return pubspec;
}

const assignPubspec = ChooseAction([
  ChooseActionItem(
    conditions: [
      isEventDataValid,
    ],
    actions: [
      AssignAction(assignPubspecAction),
    ],
  ),
]);

bool isEventDataValid(_, EventData event) {
  final data = event.data;
  return data is PubSpec;
}

PubspecInfoData assignPubspecAction(BeatState state, EventData event) {
  final data = event.data;
  return PubspecInfoData(
    projectPath: state.context.projectPath,
    pubspec: data,
  );
}

logError(_, event) {
  print(event.data);
}

class PubspecInfoData {
  final PubSpec? pubspec;
  final String projectPath;

  PubspecInfoData({
    this.pubspec,
    required this.projectPath,
  });
}
