abstract class SearchEvent {}

class OpenSearchEvent implements SearchEvent {}

class CloseSearchEvent implements SearchEvent {}

class OnSearchEvent implements SearchEvent {

  final String text;

  OnSearchEvent(this.text);
}