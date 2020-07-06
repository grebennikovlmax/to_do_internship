abstract class SearchState {

  final bool isSearching;

  SearchState(this.isSearching);
}

class OpenSearchState implements SearchState {

  final bool isSearching = true;
  final String text;

  OpenSearchState(this.text);

}

class ClosedSearchState implements SearchState {

  final bool isSearching = false;
}