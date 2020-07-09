import 'package:todointernship/model/category.dart';

abstract class CategoryListPageState {}

class LoadedCategoryPageState implements CategoryListPageState {

  final List<Category> categoryList;
  final int completedTask;
  final int incompletedTask;
  final int taskAmount;
  final double complitionTaskRate;

  LoadedCategoryPageState(this.completedTask, this.incompletedTask, this.complitionTaskRate, this.categoryList, this.taskAmount);
}

class LoadingCategoryPageState implements CategoryListPageState {}