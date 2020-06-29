import 'dart:async';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page_state.dart';
import 'package:todointernship/pages/image_picker_page/search_state.dart';
import 'package:todointernship/service/flickr_api_service.dart';

class ImagePickerBloc {

  StreamController<CategoryTheme> _pageThemeStreamController = StreamController();
  StreamController<SearchState> _searchStateStreamController = StreamController();
  StreamController<ImagePageEvent> _pageEventStreamController = StreamController();
  StreamController<ImagePickerPageState> _pageStateStreamController = StreamController();

  Stream<CategoryTheme> get pageThemeStream => _pageThemeStreamController.stream;
  Stream<SearchState> get searchStateStream => _searchStateStreamController.stream;
  Stream<ImagePickerPageState> get pageStateStream => _pageStateStreamController.stream;

  Sink<ImagePageEvent> get imagePageEventSink => _pageEventStreamController.sink;

  List<String> _imageUrl = [];
  int _page = 1;
  String searchText = '';
  bool isSearching = false;

  ImagePickerBloc() {
    _getTheme().then((value) => _pageThemeStreamController.add(value));
    _refreshImageList();
    _bindEventListener();
  }

  void dispose() {
    _pageThemeStreamController.close();
    _searchStateStreamController.close();
    _pageEventStreamController.close();
    _pageStateStreamController.close();
  }

  void _bindEventListener() {
    _pageEventStreamController.stream.listen((event) {
      switch(event.runtimeType) {
        case RefreshPageEvent:
          _refreshImageList();
          break;
        case SearchEvent:
          final text = (event as SearchEvent).text;
          _saveSearchRequest(text);
          _searchImage(text);
          break;
        case NextImagePage:
          _nextPage();
          break;
        case OpenSearchEvent:
          _openSearch();
          break;
        case CloseSearchEvent:
          _closeSearch();

      }
    });
  }

  Future<CategoryTheme> _getTheme() async {
    final pref = SharedPrefManager();
    final categoryTheme = await pref.loadTheme(0);
    return categoryTheme;
  }

  Future<void> _refreshImageList() async {
    _page = 1;
    _pageStateStreamController.add(LoadingState());
    final imageList = await FlickrApiService.shared.getRecentImages(_page);
    _imageUrl = imageList;
    _pageStateStreamController.add(LoadedImageListState(urlList: imageList));
  }

  Future<void> _searchImage(String text) async {
    searchText = text;
    _page = 1;
    _pageStateStreamController.add(LoadingState());
    final findedImages = await FlickrApiService.shared.searchPhotos(searchText: searchText,page: _page);
    _imageUrl = findedImages;
    if(_imageUrl.isEmpty) {
      _pageStateStreamController.add(EmptyImageListState());
    } else {
      _pageStateStreamController.add(LoadedImageListState(urlList: _imageUrl));
    }
  }

  Future<void> _nextPage() async {
    _page++;
    final imageList = isSearching
        ? await FlickrApiService.shared.searchPhotos(searchText: searchText,page: _page)
        : await FlickrApiService.shared.getRecentImages(_page);
    _imageUrl.addAll(imageList);
    _pageStateStreamController.add(LoadedImageListState(urlList: _imageUrl));
  }

  Future<void> _saveSearchRequest(String text) async {
    final pref = SharedPrefManager();
    pref.saveSearchRequest(text);
  }

  Future<void> _openSearch() async {
    isSearching = true;
    final pref = SharedPrefManager();
    final text = await pref.loadSearchRequest();
    _searchStateStreamController.add(OpenSearchState(text));
  }

  void _closeSearch() {
    isSearching = false;
    _searchStateStreamController.add(ClosedSearchState());
  }



}

