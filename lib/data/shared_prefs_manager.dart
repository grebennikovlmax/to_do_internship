import 'package:shared_preferences/shared_preferences.dart';

import 'package:todointernship/model/category_theme.dart';

class SharedPrefManager {

  final backgroundColor = 'backgroundColor_';
  final primaryColor = 'primaryColor_';
  final lastSearchRequest = 'last_search_request';

  Future<void> saveTheme(CategoryTheme theme, int id) async {
    final pref = await SharedPreferences.getInstance();
    final stringId = id.toString();
    pref.setInt(backgroundColor + stringId, theme.backgroundColor);
    pref.setInt(primaryColor + stringId, theme.primaryColor);
  }

  Future<void> deleteTheme(int id) async {
    var pref = await SharedPreferences.getInstance();
    var stringId = id.toString();
    pref.remove(backgroundColor + stringId);
    pref.remove(primaryColor + stringId);
  }

  Future<CategoryTheme> loadTheme(int id) async {
    final pref = await SharedPreferences.getInstance();
    final stringId = id.toString();
    return CategoryTheme(
        backgroundColor: pref.getInt(backgroundColor + stringId),
        primaryColor:  pref.getInt(primaryColor + stringId)
        );
  }

  Future<void> saveHiddenFlag(bool flag, int id) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool('hidden_flag_$id', flag);
  }

  Future<bool> getHiddenFlag(int id) async {
    final pref = await SharedPreferences.getInstance();
    final flag =  pref.getBool('hidden_flag_$id') ?? false;
    return flag;
  }

  Future<void> saveSearchRequest(String text) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(lastSearchRequest, text);
  }

  Future<String> loadSearchRequest() async {
    final pref = await SharedPreferences.getInstance();
    final text = pref.getString(lastSearchRequest);
    return text;
  }
}
