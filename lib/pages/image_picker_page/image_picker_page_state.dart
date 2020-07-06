abstract class ImagePickerPageState {

}

class LoadingState implements ImagePickerPageState {

}

class LoadedImageListState implements ImagePickerPageState {

  final List<String> urlList;

  LoadedImageListState({this.urlList});
}

class EmptyImageListState implements ImagePickerPageState {

}