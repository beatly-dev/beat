import 'dart:convert';
import 'dart:io';

import 'package:beat_config/beat_config.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';

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

  reconstructTree() {
    _roots.clear();
    final nodes = _nodes.values;
    for (final node in nodes) {
      final substations =
          node.substationConfigs.values.expand((element) => element);
      node.children.clear();
      // set children
      for (final substation in substations) {
        final subName = substation.childBase;
        final subNode = _nodes[subName];
        if (subNode == null) {
          continue;
        }
        final parentEnumName = substation.parentBase;
        final parentFieldName = substation.parentField;
        // set parent
        subNode.parent = parentEnumName;
        node.children[parentFieldName] ??= [];
        node.children[parentFieldName]!.add(subNode);
      }
    }

    for (final node in nodes) {
      final parent = node.parent;
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
}
