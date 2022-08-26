import 'dart:convert';
import 'dart:io';

import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';

final inMemoryStationData = Resource<StationDataStore>(
  () async {
    final file = File(beatJsonLocation);
    var oldData = '';

    log.info('Initialize beat data');
    if (await file.exists()) {
      oldData = await file.readAsString();
      final oldJson = jsonDecode(oldData);
      if (oldJson == null) {
        return StationDataStore();
      }
      return StationDataStore.fromJson(oldJson);
    } else {
      return StationDataStore();
    }
  },
  dispose: (stationData) async {
    final output = File(beatJsonLocation);
    var oldJson = '';
    if (await output.exists()) {
      oldJson = await output.readAsString();
    } else {
      await output.create(recursive: true);
    }

    final newJson = jsonEncode(stationData);
    if (oldJson != newJson) {
      log.info('Store beat data');
      await output.writeAsString(newJson);
    }
  },
);
