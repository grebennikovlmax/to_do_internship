import 'dart:async';
import 'dart:io';

import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page_state.dart';
import 'package:todointernship/data/flickr_api_service.dart';

class ImagePickerBloc {

  StreamController<ImagePageEvent> _pageEventStreamController = StreamController();
  StreamController<ImagePickerPageState> _pageStateStreamController = StreamController();

  Stream<ImagePickerPageState> get pageStateStream => _pageStateStreamController.stream;

  Sink<ImagePageEvent> get imagePageEventSink => _pageEventStreamController.sink;

  List<String> _imageUrl = [];
  int _page = 1;
  String _searchText = '';
  bool _isSearching = false;

  ImagePickerBloc() {
    _refreshImageList();
    _bindEventListener();
  }

  void _bindEventListener() {
    _pageEventStreamController.stream.listen((event) {
      switch(event.runtimeType) {
        case RefreshPageEvent:
          _refreshImageList();
          break;
        case NextImagePage:
          _nextPage();
          break;
        case SearchImageEvent:
          _searchImage(event);
          break;
      }
    });
  }

  Future<void> _refreshImageList() async {
    _isSearching = false;
    _page = 1;
    _pageStateStreamController.add(LoadingState());
    try {
      final imageList = await FlickrApiService.shared.getRecentImages(_page).timeout(Duration(seconds: 4));
      _imageUrl = imageList;
      _pageStateStreamController.add(LoadedImageListState(urlList: imageList));
    } catch(e) {
      if(e.runtimeType == StateError) {
        return;
      }
      _checkError(e);
    }
  }

  Future<void> _searchImage(SearchImageEvent event) async {
    _searchText = event.text;
    _isSearching = true;
    _page = 1;
    _pageStateStreamController.add(LoadingState());
    try {
      final findedImages = await FlickrApiService.shared.searchPhotos(searchText: event.text,page: _page);
      _imageUrl = findedImages;
      if(_imageUrl.isEmpty) {
        _pageStateStreamController.add(EmptyImageListState('Ничего не найдено'));
      } else {
        _pageStateStreamController.add(LoadedImageListState(urlList: _imageUrl));
      }
    } catch(e) {
      _checkError(e);
    }

  }

  void _checkError (Exception err) {
    if(err.runtimeType == SocketException) {
      _pageStateStreamController.add(EmptyImageListState('Проблема с подключением попробуйте позже'));
    } else {
      _pageStateStreamController.add(EmptyImageListState('Возникла проблема с сервисом попробуйте позже'));
    }
  }

  Future<void> _nextPage() async {
    _page++;
    final imageList = _isSearching
        ? await FlickrApiService.shared.searchPhotos(searchText: _searchText,page: _page)
        : await FlickrApiService.shared.getRecentImages(_page);
    _imageUrl.addAll(imageList);
    _pageStateStreamController.add(LoadedImageListState(urlList: _imageUrl));
  }
  
  void dispose() {
    _pageEventStreamController.close();
    _pageStateStreamController.close();
  }

}

