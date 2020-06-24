
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todointernship/model/category_theme.dart';

class SharedPrefTheme {

  final backgroundColor = 'backgroundColor_';
  final primaryColor = 'primaryColor_';

  Future<void> saveTheme(CategoryTheme theme, int id) async {
    final pref = await SharedPreferences.getInstance();
    final stringId = id.toString();
    pref.setInt(backgroundColor + stringId, theme.backgroundColor);
    pref.setInt(primaryColor + stringId, theme.primaryColor);
  }

  Future<CategoryTheme> loadTheme(int id) async {
    final pref = await SharedPreferences.getInstance();
    final stringId = id.toString();
    return CategoryTheme(
        backgroundColor: pref.getInt(backgroundColor + stringId),
        primaryColor:  pref.getInt(primaryColor + stringId)
        );
    }
}
