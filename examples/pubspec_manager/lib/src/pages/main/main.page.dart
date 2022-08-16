import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../beats/route/route.dart';

class HomePage extends StatefulWidget {
  const HomePage(
    this.routeStation, {
    Key? key,
  }) : super(key: key);
  final MainRouteBeatStation routeStation;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    widget.routeStation.addContextListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final recentProjects = widget.routeStation.currentState.context;
    return MacosWindow(
      child: MacosScaffold(
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MacosTabView(
                          controller: MacosTabController(length: 1),
                          tabs: const [
                            MacosTab(
                              label: 'Recent Projects',
                              active: true,
                            ),
                          ],
                          children: [
                            ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: recentProjects?.length ?? 0,
                              separatorBuilder: (_, __) {
                                return const SizedBox(height: 16);
                              },
                              itemBuilder: (context, index) {
                                final project = recentProjects?[index];
                                if (project == null) {
                                  return const SizedBox.shrink();
                                }
                                return MacosListTile(
                                  title: Text(
                                    project.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  leadingWhitespace: 0,
                                  subtitle: Tooltip(
                                    message: project.path,
                                    child: Text(
                                      project.path,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  onClick: () {},
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      PushButton(
                        buttonSize: ButtonSize.large,
                        onPressed: () async {
                          final path =
                              await FilePicker.platform.getDirectoryPath(
                                    lockParentWindow: true,
                                  ) ??
                                  '';
                          widget.routeStation.send.$gotoExplorer(
                            data: RouteArgs(context: context, args: path),
                          );
                        },
                        child: const Text('Open a flutter project'),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
