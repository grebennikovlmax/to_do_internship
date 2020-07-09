import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/data/theme_list_data.dart';
import 'package:todointernship/theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, Map<int, CategoryTheme>> {

  final SharedPrefManager _sharedPref;
  Map<int, CategoryTheme> _themes = {};

  ThemeBloc(this._sharedPref) : super(null);

  @override
  Map<int, CategoryTheme> get state => _themes;

  @override
  Stream<Map<int, CategoryTheme>> mapEventToState(ThemeEvent event) async* {
    if (event is DeleteThemeEvent) {
      _deleteTheme(event);
    } else if (event is SaveThemeEvent) {
      yield* _saveTheme(event);
    } else if (event is LoadThemeEvent) {
      _loadTheme(event);
    } else if (event is ChangeThemeEvent) {
      yield* _changeTheme(event);
    } else if (event is RefreshThemeEvent) {
      yield _themes;
    }
  }

  Stream<Map<int, CategoryTheme>> _saveTheme(SaveThemeEvent event) async*{
    var theme = _setupCategoryTheme(event.color);
    _themes[event.id] = theme;
    _sharedPref.saveTheme(theme, event.id);
    yield _themes;
  }

  Future<void> _loadTheme(LoadThemeEvent event) async {
    if(!_themes.containsKey(event.id)) {
      var theme = await _sharedPref.loadTheme(event.id);
      _themes[event.id] = theme;
    }
  }

  void _deleteTheme(DeleteThemeEvent event) {
    _themes.remove(event.id);
    _sharedPref.deleteTheme(event.id);
  }

  Stream<Map<int, CategoryTheme>> _changeTheme(ChangeThemeEvent event) async* {
    var theme = _setupCategoryTheme(event.color);
    _themes[event.id] = theme;
    _sharedPref.saveTheme(theme, event.id);
    yield Map.from(_themes);
  }

  CategoryTheme _setupCategoryTheme(int color) {
    if(color == null) {
      return ThemeListData.all.mainTheme;
    }
    return ThemeListData.all.themes.firstWhere((element) => element.backgroundColor == color);
  }

}