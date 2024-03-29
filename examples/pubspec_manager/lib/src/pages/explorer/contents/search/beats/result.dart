import 'dart:async';

import 'package:flutter_beat/flutter_beat.dart';
import 'package:pub_api_client/pub_api_client.dart';

part 'result.beat.dart';

@BeatStation(contextType: PubSearchRequest)
@Beat(
  event: 'load',
  to: SearchResult.loading,
  actions: [AssignAction(assignSearchTargetAction)],
)
@Beat(
  event: 'clear',
  to: SearchResult.idle,
  actions: [AssignAction(clearContextAction)],
)
enum SearchResult {
  idle,

  @Invokes(
    [
      InvokeFuture(
        loadData,
        onDone: AfterInvoke(
          to: SearchResult.loaded,
          actions: [AssignAction(assignFetchedResultsAction)],
        ),
      ),
    ],
  )
  loading,

  @Invokes(
    [
      InvokeFuture(
        logLoadedData,
      ),
    ],
  )
  loaded,
  error,
}

PubSearchRequest clearContextAction(state, event) {
  return PubSearchRequest('', null);
}

PubSearchRequest assignSearchTargetAction(state, EventData event) {
  final target = event.data as String? ?? '';
  return PubSearchRequest(target, null);
}

PubSearchRequest assignFetchedResultsAction(BeatState state, EventData event) {
  final context = state.context as PubSearchRequest;
  final results = event.data as SearchResults;
  return PubSearchRequest(context.target, results);
}

Future<SearchResults> loadData(BeatState state, _) async {
  final request = state.context as PubSearchRequest;
  final client = PubClient();
  final result = await client.search(request.target);
  return result;
}

logLoadedData(state, event) async {
  print('Loaded');
}

class PubSearchRequest {
  final String target;
  final Timer? timer;
  final SearchResults? results;

  PubSearchRequest(this.target, this.results, {this.timer});
}
