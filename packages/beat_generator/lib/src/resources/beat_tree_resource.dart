import 'dart:convert';
import 'dart:io';

import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';

import '../utils/string.dart';

const jsonLocation = '$entryPointDir/beat_tree.json';
final inMemoryBeatTree = Resource<BeatTreeSharedResource>(
  () async {
    final file = File(jsonLocation);
    var oldData = '';
    List<BeatStationNode> oldTree = [];
    if (await file.exists()) {
      print("Load old beat tree data");
      oldData = await file.readAsString();
      final oldJson = jsonDecode(oldData) as List<dynamic>;
      for (final item in oldJson) {
        final node = BeatStationNode.fromJson(item);
        oldTree.add(node);
      }
    }
    final beatTree = BeatTreeSharedResource._(oldTree);
    await beatTree._initialize();
    print("Beat tree initialized");
    return beatTree;
  },
  dispose: (beatTree) async {
    final output = File(jsonLocation);
    var oldJson = '';
    if (await output.exists()) {
      oldJson = await output.readAsString();
    } else {
      await output.create(recursive: true);
    }

    final newJson = jsonEncode(beatTree._roots);
    if (oldJson != newJson) {
      print("Beat tree is updated to $jsonLocation");
      await output.writeAsString(newJson);
    }
  },
);

class BeatTreeSharedResource {
  final _nodes = <String, BeatStationNode>{};
  final List<BeatStationNode> _roots;

  BeatTreeSharedResource._(this._roots);

  _initialize() async {
    print("Initializing beat tree...");
    for (final root in _roots) {
      await _initializeBeatNodeMap(root);
    }
  }

  _initializeBeatNodeMap(BeatStationNode node) async {
    _nodes[node.info.baseEnumName] = node;
    for (final child in node.children.values.expand((element) => element)) {
      await _initializeBeatNodeMap(child);
    }
  }

  /// TODO: Need Performance Improvements

  reconstructTree() {
    _roots.clear();
    final nodes = _nodes.values;

    // reset tree info
    for (final node in nodes) {
      node.children.clear();
      node.parentBase = '';
      node.parentField = '';
    }

    // rebuild tree
    for (final node in nodes) {
      final substations =
          node.substationConfigs.values.expand((element) => element);
      // set children
      for (final substation in substations) {
        final subEnumName = substation.childBase;
        final subNode = _nodes[subEnumName];
        if (subNode == null) {
          continue;
        }

        /// TODO: deal with multi parent
        final parentEnumName = substation.parentBase;
        final parentFieldName = substation.parentField;
        // set parent
        subNode.parentBase = parentEnumName;
        subNode.parentField = parentFieldName;
        node.children[parentFieldName] ??= [];
        node.children[parentFieldName]!.add(subNode);
      }
    }

    // set roots
    for (final node in nodes) {
      final parent = node.parentBase;
      // if there is no parent, then it is root
      if (parent.isEmpty) {
        _roots.add(node);
      }
    }
  }

  addNode(BeatStationNode node) async {
    _nodes[node.info.baseEnumName] = node;
    reconstructTree();
  }

  removeNode(BeatStationNode node) async {
    _nodes.remove(node.info.baseEnumName);
    reconstructTree();
  }

  Future<List<BeatStationNode>> getRelatedStations(
    String name, {
    bool includeRoot = true,
  }) async {
    final root = _nodes[name]!;
    final stations = <BeatStationNode>[root];
    if (!includeRoot && root.info.baseEnumName == name) {
      stations.clear();
    }
    final children = root.children.values.expand((element) => element);
    for (final child in children) {
      stations.addAll(await getRelatedStations(child.info.baseEnumName));
    }
    return stations;
  }

  BeatStationNode getNode(String name) => _nodes[name]!;

  List<BeatStationNode> getAllNode() => _nodes.values.toList();
  List<BeatStationNode> routeBetween({String from = '', required String to}) {
    if (from == to || to == '') {
      return [];
    }
    final currentStation = getNode(to);
    final parent = currentStation.parentBase;
    return [...routeBetween(from: from, to: parent), currentStation];
  }

  String substationRouteBetween({String from = '', required String to}) {
    final routes = routeBetween(to: to, from: from);
    return routes.map((station) {
      return toSubstationFieldName(station.info.baseEnumName);
    }).join('.');
  }
}
