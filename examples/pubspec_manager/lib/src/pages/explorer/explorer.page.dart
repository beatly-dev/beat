import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../args/args.dart';
import '../../beats/route/route.dart';
import '../../db/recent_projects.dart';
import 'beats/pubspec/pubspec.dart';
import 'contents/search/beats/input.dart';
import 'contents/search/beats/result.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage(
    this.routeStation, {
    Key? key,
    required this.folderPath,
  }) : super(key: key);
  final MainRouteBeatStation routeStation;
  final String folderPath;

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final inputStataion = SearchInputBeatStation()..start();
  final resultStation = SearchResultBeatStation()..start();
  late final PubspecInfoBeatStation pubspecInfoStation;
  String get folderPath => widget.folderPath;

  @override
  void initState() {
    pubspecInfoStation = PubspecInfoBeatStation(
      initialContext: PubspecInfoData(
        projectPath: widget.folderPath,
      ),
    )..addListener(handlePubspecInfo);
    pubspecInfoStation.start();
    inputStataion.addListener(loadData);
    super.initState();
  }

  storeProjects(String name) async {
    final isar = await Isar.open([RecentProjectsSchema]);
    await isar.writeTxn(() async {
      await isar.recentProjects.put(
        RecentProjects()
          ..path = folderPath
          ..name = name,
      );
    });
    await isar.close();
  }

  @override
  void dispose() {
    super.dispose();
  }

  handlePubspecInfo() {
    pubspecInfoStation.exec(
      onPubspecInfoLoaded: () {
        storeProjects(pubspecInfoStation.currentState.context!.pubspec!.name!);
      },
      onPubspecInfoError: () {
        /// TODO:
        /// Move to the beat station as a service.
        /// if beat support explicity event data type, then use it.
        return widget.routeStation.$gotoHome(data: RouteArgs(context: context));
      },
      orElse: () {
        // TODO: if beat support Notifier or stream, then use it.
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  loadData() {
    if (inputStataion.currentState.isSearching$) {
      resultStation.send.$load(data: inputStataion.currentState.context);
    }
  }

  var _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      titleBar: TitleBar(
        title: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: MacosBackButton(
                  onPressed: () => widget.routeStation.send
                      .$gotoHome(data: RouteArgs(context: context)),
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            Tooltip(
              message: widget.folderPath,
              child: Text(
                pubspecInfoStation.map(
                  onPubspecInfoLoading: () => 'Parsing...',
                  onPubspecInfoLoaded: () =>
                      pubspecInfoStation.currentState.context!.pubspec?.name ??
                      'Load error',
                  orElse: () => '',
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        centerTitle: false,
        height: 50,
      ),
      sidebar: Sidebar(
        minWidth: 200,
        dragClosed: false,
        bottom: MacosListTile(
          leading: const MacosIcon(CupertinoIcons.settings),
          title: const Text(
            'Settings',
          ),
          onClick: () {},
        ),
        builder: (context, scrollController) {
          return SidebarItems(
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.home),
                label: Text('Your packages'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.search),
                label: Text('Other packages'),
              ),
            ],
            currentIndex: _pageIndex,
            onChanged: (index) {
              setState(() {
                _pageIndex = index;
              });
            },
          );
        },
      ),
      child: IndexedStack(
        index: _pageIndex,
        children: [
          MacosScaffold(
            children: [
              ContentArea(
                builder: ((context, scrollController) {
                  return Center(
                    child: Text(
                      'Home ${widget.folderPath}',
                    ),
                  );
                }),
              ),
              ResizablePane(
                resizableSide: ResizableSide.left,
                minWidth: 300,
                startWidth: 300,
                builder: (_, __) => StreamBuilder<PubspecInfoData?>(
                  stream: pubspecInfoStation.contextStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data?.pubspec?.name ?? 'PATH');
                    }
                    return const Text('Loading');
                  },
                ),
              ),
            ],
          ),
          MacosScaffold(
            children: [
              ContentArea(
                builder: ((context, scrollController) {
                  return Center(
                    child: Text(
                      'Explore ${widget.folderPath}',
                    ),
                  );
                }),
              ),
            ],
          ),
          MacosScaffold(
            children: [
              ContentArea(
                builder: ((context, scrollController) {
                  return Center(
                    child: Text(
                      'Settings ${widget.folderPath}',
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchedResultWidget extends StatefulWidget {
  const SearchedResultWidget({required this.station, Key? key})
      : super(key: key);
  final SearchResultBeatStation station;

  @override
  State<SearchedResultWidget> createState() => _SearchedResultWidgetState();
}

class _SearchedResultWidgetState extends State<SearchedResultWidget> {
  @override
  void initState() {
    widget.station.addListener(handleResult);
    super.initState();
  }

  @override
  void dispose() {
    widget.station.removeListener(handleResult);
    super.dispose();
  }

  handleResult() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    final state = station.currentState;
    if (state.isIdle$) {
      return Center(
        child: Text('Type what you want to search for. $args'),
      );
    }

    if (state.isLoading$) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final results = state.context!.results!.packages;

    if (results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView(
      children: [
        ...results.map((package) {
          return MacosListTile(
            title: Text(package.package),
          );
        }).toList(),
      ],
    );
  }
}
