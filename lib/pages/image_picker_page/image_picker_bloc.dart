import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page_state.dart';
import 'package:todointernship/data/flickr_api_service.dart';

class ImagePickerBloc extends Bloc<ImagePageEvent, ImagePickerPageState> {

  final FlickrApiService _apiService;

  List<String> _imageUrl = [];
  int _page = 1;
  String _searchText = '';
  bool _isSearching = false;

  ImagePickerBloc(FlickrApiService apiService) :
        _apiService = apiService,
        super(null)
  {
   this.add(RefreshPageEvent());
  }

  @override
  Stream<ImagePickerPageState> mapEventToState(ImagePageEvent event) async* {
    if(event is RefreshPageEvent) {
      yield* _refreshImageList();
    } else if (event is NextImagePage) {
      yield* _nextPage();
    } else if (event is SearchImageEvent) {
      yield* _searchImage(event);
    }
  }

  Stream<ImagePickerPageState> _refreshImageList() async* {
    _isSearching = false;
    _page = 1;
    yield LoadingState();
    try {
      final imageList = await _apiService.getRecentImages(_page);
      _imageUrl = imageList;
      yield LoadedImageListState(urlList: _imageUrl);
    } catch(e) {
      print(e);
      yield _checkError(e);
    }
  }

  Stream<ImagePickerPageState> _searchImage(SearchImageEvent event) async* {
    _searchText = event.text;
    _isSearching = true;
    _page = 1;
    yield LoadingState();
    try {
      final findedImages = await _apiService.searchPhotos(searchText: event.text,page: _page);
      _imageUrl = findedImages;
      if(_imageUrl.isEmpty) {
        yield EmptyImageListState('Ничего не найдено');
      } else {
        yield LoadedImageListState(urlList: _imageUrl);
      }
    } catch(e) {
      yield _checkError(e);
    }
  }

  EmptyImageListState _checkError (dynamic err) {
    if(err.runtimeType == SocketException) {
      return EmptyImageListState('Проблема с подключением попробуйте позже');
    } else {
      return EmptyImageListState('Возникла проблема с сервисом попробуйте позже');
    }
  }

  Stream<ImagePickerPageState> _nextPage() async* {
    _page++;
    final imageList = _isSearching
        ? await FlickrApiService.shared.searchPhotos(searchText: _searchText,page: _page)
        : await FlickrApiService.shared.getRecentImages(_page);
    _imageUrl.addAll(imageList);
    yield LoadedImageListState(urlList: _imageUrl);
  }

}