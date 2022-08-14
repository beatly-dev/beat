import 'package:flutter/material.dart';

import 'pages/main/main.page.dart';

class PubspecManager extends StatelessWidget {
  const PubspecManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}
