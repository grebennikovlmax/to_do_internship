import 'package:todointernship/model/category.dart';

abstract class CategoryListPageState {

}

class LoadedPageState implements CategoryListPageState {

  final List<Category> categoryList;
  final int completedTask;
  final int incompletedTask;
  final int taskAmount;
  final double complitionTaskRate;

  LoadedPageState(this.completedTask, this.incompletedTask, this.complitionTaskRate, this.categoryList, this.taskAmount);
}