import 'dart:async';

import 'package:beat/beat.dart';
import 'package:pub_api_client/pub_api_client.dart';

part 'result.beat.dart';

@BeatStation(contextType: PubSearchRequest)
@Beat(
  event: 'load',
  to: PubSearchResult.loading,
  actions: [AssignAction(assignSearchTargetAction)],
)
@Beat(
  event: 'clear',
  to: PubSearchResult.idle,
  actions: [AssignAction(clearContextAction)],
)
enum PubSearchResult {
  idle,

  @Invokes(
    [
      InvokeFuture(
        loadData,
        onDone: AfterInvoke(
          to: PubSearchResult.loaded,
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
  print('Assign $results');
  return PubSearchRequest(context.target, results);
}

loadData(BeatState state, event) async {
  final request = state.context as PubSearchRequest;
  final client = PubClient();
  print('Load data for ${request.target}');
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
