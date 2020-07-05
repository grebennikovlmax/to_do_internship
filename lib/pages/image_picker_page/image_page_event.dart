abstract class ImagePageEvent {

}

class RefreshPageEvent implements ImagePageEvent {

}

class SearchImageEvent implements ImagePageEvent {
  final String text;

  SearchImageEvent({this.text});
}

class NextImagePage implements ImagePageEvent {}
