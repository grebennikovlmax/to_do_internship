import 'dart:async';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/pages/image_picker_page/search_state.dart';
import 'package:todointernship/pages/image_picker_page/search_event.dart';

class SearchBarBloc {

  final SharedPrefManager _prefManager = SharedPrefManager();

  StreamController<SearchState> _searchStateStreamController = StreamController();
  StreamController<SearchEvent> _searchEventStreamController = StreamController();

  Sink<SearchEvent> get searchEventSink => _searchEventStreamController.sink;

  Stream<SearchState> get searchStateStream => _searchStateStreamController.stream;

  SearchBarBloc() {
    _bindSearchEventListener();
  }

  void _bindSearchEventListener() {
    _searchEventStreamController.stream.listen((event) {
      switch(event.runtimeType) {
        case CloseSearchEvent:
          _closeSearch();
          break;
        case OpenSearchEvent:
          _openSearch();
          break;
        case OnSearchEvent:
          _saveSearchRequest(event);
          break;
      }
    });
  }


  Future<void> _saveSearchRequest(OnSearchEvent event) async {
    _prefManager.saveSearchRequest(event.text);
  }

  Future<void> _openSearch() async {
    var text = await _prefManager.loadSearchRequest();
    _searchStateStreamController.add(OpenSearchState(text));
  }

  void _closeSearch() {
    _searchStateStreamController.add(ClosedSearchState());
  }

  void dispose() {
    _searchStateStreamController.close();
    _searchEventStreamController.close();
  }
}
