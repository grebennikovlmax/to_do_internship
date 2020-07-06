import 'dart:async';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/data/theme_list_data.dart';
import 'package:todointernship/theme_event.dart';

class ThemeBloc {
  
  final sharedPref = SharedPrefManager();

  final _themeStreamController = StreamController<Map<int, CategoryTheme>>.broadcast(sync: true);
  final _themeEventStreamController = StreamController<ThemeEvent>();
  
  Sink get themeEventSink => _themeEventStreamController.sink;
  
  Stream get themeStream => _themeStreamController.stream;

  Map<int, CategoryTheme> _themes = {};
  
  ThemeBloc() {
    _bindEventListener();
  }

  void _bindEventListener() {
    _themeEventStreamController.stream.listen((event) { 
      switch(event.runtimeType) {
        case LoadThemeEvent:
          _loadTheme(event);
          break;
        case SaveThemeEvent:
          _saveTheme(event);
          break;
        case RefreshThemeEvent:
          _refreshList();
          break;
        case ChangeThemeEvent:
          _changeTheme(event);
          break;
        case DeleteThemeEvent:
          _deleteTheme(event);
          break;
      }
    });
  }
  
  Future<void> _loadTheme(LoadThemeEvent event) async {
    if(!_themes.containsKey(event.id)) {
      var theme = await sharedPref.loadTheme(event.id);
      _themes[event.id] = theme;
    }
  }

  void _saveTheme(SaveThemeEvent event) {
    var theme = _setupCategoryTheme(event.color);
    _themes[event.id] = theme;
    sharedPref.saveTheme(theme, event.id);
    _refreshList();
  }

  void _changeTheme(ChangeThemeEvent event) {
    var theme = _setupCategoryTheme(event.color);
    _themes[event.id] = theme;
    sharedPref.saveTheme(theme, event.id);
    _refreshList();
  }

  void _deleteTheme(DeleteThemeEvent event) {
    _themes.remove(event.id);
    sharedPref.deleteTheme(event.id);
  }

  CategoryTheme _setupCategoryTheme(int color) {
    if(color == null) {
      return ThemeListData.all.mainTheme;
    }
    return ThemeListData.all.themes.firstWhere((element) => element.backgroundColor == color);
  }

  void _refreshList() {
    _themeStreamController.add(_themes);
  }
  
  void dispose() {
    _themeStreamController.close();
    _themeEventStreamController.close();
  }
}
