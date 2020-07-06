abstract class ImagePageEvent {

}

class RefreshPageEvent implements ImagePageEvent {

}

class SearchEvent implements ImagePageEvent {
  final String text;

  SearchEvent({this.text});
}

class NextImagePage implements ImagePageEvent {

}

class OpenSearchEvent implements ImagePageEvent {

}

class CloseSearchEvent implements ImagePageEvent {

}