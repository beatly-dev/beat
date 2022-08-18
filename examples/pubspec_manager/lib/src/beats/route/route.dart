import 'package:flutter_beat/flutter_beat.dart';
import 'package:isar/isar.dart';

import '../../db/recent_projects.dart';
import 'constants.dart';

part 'route.beat.dart';

@WithFlutter()
@BeatStation(contextType: List<RecentProjects>)
@gotoHomeBeat
enum MainRoute {
  @gotoExplorerBeat
  @Invokes([loadRecentPostsService])
  home,
  explorer,
}

const loadRecentPostsService = InvokeFuture(
  loadRecentPosts,
  onDone: AfterInvoke(to: '', actions: [AssignAction(assignRecentProjects)]),
);

Future<List<RecentProjects>> loadRecentPosts(BeatState state, _) async {
  final isar = await Isar.open([RecentProjectsSchema]);
  final recentProjects = await isar.recentProjects
      .where(sort: Sort.desc)
      .distinctByPath()
      .limit(10)
      .findAll();
  await isar.close();
  return recentProjects;
}

List<RecentProjects> assignRecentProjects(_, EventData data) {
  return data.data;
}

const gotoExplorerBeat = Beat(
  event: 'gotoExplorer',
  to: MainRoute.explorer,
  actions: [
    gotoExplorerAction,
  ],
);
const gotoHomeBeat = Beat(
  event: 'gotoHome',
  to: MainRoute.home,
  actions: [
    gotoHomeAction,
  ],
);

gotoExplorerAction(_, event) {
  final data = event.data;
  if (data is! RouteArgs) {
    return;
  }

  Navigator.of(data.context).pushNamed(pathExplorer, arguments: data.args);
}

gotoHomeAction(_, EventData event) {
  final data = event.data;
  if (data is! RouteArgs) {
    return;
  }
  final context = data.context;
  final args = data.args;
  var foundHome = false;
  Navigator.of(context).popUntil(
    (route) {
      foundHome = ModalRoute.withName(pathMain)(route);
      return foundHome;
    },
  );

  if (foundHome) {
    return;
  }

  Navigator.of(context).pushNamed(pathMain, arguments: args);
}

class RouteArgs<Args> {
  final BuildContext context;
  final dynamic args;

  RouteArgs({
    required this.context,
    this.args,
  });
}
