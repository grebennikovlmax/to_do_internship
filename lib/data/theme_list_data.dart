import 'package:todointernship/model/category_theme.dart';

class ThemeListData {

  static final all = ThemeListData._privateConstructor();

  ThemeListData._privateConstructor();

  final mainTheme = CategoryTheme(
    primaryColor: 4284613358,
    backgroundColor: 4288653530,
  );

  List<CategoryTheme> themes = [
    CategoryTheme(
      primaryColor: 4294198070,
      backgroundColor: 4281788404,
    ),
    CategoryTheme(
      primaryColor: 4294924066,
      backgroundColor: 4294951970,
    ),
    CategoryTheme(
      primaryColor: 4294951175,
      backgroundColor: 4278666751,
    ),
    CategoryTheme(
      primaryColor: 4283215696,
      backgroundColor: 4289678508,
    ),
    CategoryTheme(
      primaryColor: 4281112816,
      backgroundColor: 4281135334,
    ),
    CategoryTheme(
      primaryColor: 4284613358,
      backgroundColor: 4288653530,
    )
  ];
}