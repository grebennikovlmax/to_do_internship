import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/category_theme.dart';

abstract class CategoryListPageState {

}

class LoadedPageState implements CategoryListPageState {

  final List<Category> categoryList;
  final int completedTask;
  final int incompletedTask;
  final int taskAmount;
  final double complitionTaskRate;
  final Map<int, CategoryTheme> themes;

  LoadedPageState(this.completedTask, this.incompletedTask, this.complitionTaskRate, this.categoryList, this.taskAmount, this.themes);
}