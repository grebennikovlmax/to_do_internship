import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/category_theme.dart';

class Category {
  String name;
  List<Task> tasks = [];
  CategoryTheme theme;

  Category(this.name,this.theme);

  int get taskCount => tasks.length;
  int get completedTasks => tasks.where((task) => task.isCompleted).length;
  int get incompletedTasks => taskCount - completedTasks;
  double get completion => completedTasks / taskCount;

  set newTask(Task task) => tasks.add(task);
}