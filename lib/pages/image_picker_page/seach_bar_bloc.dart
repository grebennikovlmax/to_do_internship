import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/pages/image_picker_page/search_state.dart';
import 'package:todointernship/pages/image_picker_page/search_event.dart';

class SearchBarBloc extends Bloc<SearchEvent, SearchState> {

  final SharedPrefManager _prefManager;

  SearchBarBloc(this._prefManager) : super(ClosedSearchState());

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is CloseSearchEvent) {
      yield ClosedSearchState();
    } else if (event is OpenSearchEvent) {
      yield* _openSearch();
    } else if (event is OnSearchEvent) {
      _prefManager.saveSearchRequest(event.text);
    } else if (event is CloseSearchEvent) {
      yield ClosedSearchState();
    }
  }

  Stream<SearchState> _openSearch() async* {
    var text = await _prefManager.loadSearchRequest();
    yield OpenSearchState(text);
  }

}
