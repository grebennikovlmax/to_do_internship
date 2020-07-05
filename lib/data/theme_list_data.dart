import 'package:todointernship/model/category_theme.dart';

class ThemeListData {

  static final all = ThemeListData._privateConstructor();

  final mainTheme = CategoryTheme(
    primaryColor: 4284613358,
    backgroundColor: 4288653530,
  );

  List<CategoryTheme> themes;

  ThemeListData._privateConstructor() {
    themes = [
    CategoryTheme(
      primaryColor: 4278214689,
      backgroundColor: 4287883440,
    ),
    CategoryTheme(
      primaryColor: 4279192993,
      backgroundColor: 4285178091,
    ),
    CategoryTheme(
      primaryColor: 4280979146,
      backgroundColor: 4294942504,
    ),
    CategoryTheme(
      primaryColor: 4282334419,
      backgroundColor: 4294953512,
    ),
    CategoryTheme(
      primaryColor: 4280473195,
      backgroundColor: 4294922792,
    ),
    mainTheme,
    ];
  }

}