abstract class ImageEvent {}

class NewImageEvent implements ImageEvent {
  final String url;

  NewImageEvent(this.url);

}

class DeleteImageEvent implements ImageEvent {
  final String path;

  DeleteImageEvent(this.path);
}

class UpdateImageEvent implements ImageEvent {}