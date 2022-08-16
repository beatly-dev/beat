import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import 'beats/route/constants.dart';
import 'beats/route/route.dart';
import 'pages/explorer/explorer.page.dart';
import 'pages/main/main.page.dart';

class PubspecManager extends StatelessWidget {
  PubspecManager({Key? key}) : super(key: key);
  final routeStation = MainRouteBeatStation()..start();

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      onGenerateRoute: (settings) {
        final arg = settings.arguments;
        final routes = {
          pathMain: HomePage(routeStation),
          pathExplorer: ExplorerPage(
            routeStation,
            folderPath: arg is String ? arg : '',
          ),
        };
        final page = routes[settings.name ?? '/']!;
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return page;
          },
        );
      },
    );
  }
}
