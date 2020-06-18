import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/category_theme.dart';

class Category {
  String _name;
  List<Task> _tasks = [];
  CategoryTheme _theme;

  Category(this._name,this._theme);

  String get name => _name;
  int get taskCount => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get incompletedTasks => taskCount - completedTasks;

  set newTask(Task task) => _tasks.add(task);
}