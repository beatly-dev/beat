import 'package:flutter/material.dart';

import '../../args/args.dart';
import '../../beats/search/input.dart';
import '../../beats/search/result.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final inputStataion = SearchInputBeatStation()..start();
  final resultStation = SearchResultBeatStation()..start();

  @override
  void initState() {
    inputStataion.addListener(loadData);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadData() {
    if (inputStataion.currentState.isSearchInputTyped$) {
      resultStation.send.$load(inputStataion.currentState.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            onChanged: (text) {
              if (text.isEmpty) {
                resultStation.send.$clear();
                inputStataion.send.$clear();
              } else {
                inputStataion.send.$type(text);
              }
            },
          ),
          Expanded(
            child: SearchedResultWidget(
              station: resultStation,
            ),
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
    if (state.isSearchResultIdle$) {
      return Center(
        child: Text('Type what you want to search for. $args'),
      );
    }

    if (state.isSearchResultLoading$) {
      return const Center(child: Text('Loading data...'));
    }

    final results = state.context!.results!.packages;

    if (results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView(
      children: [
        ...results.map((package) {
          return ListTile(
            title: Text(package.package),
          );
        }).toList(),
      ],
    );
  }
}
