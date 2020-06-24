import 'package:todointernship/model/task.dart';

class TaskListState {
  final completedIsHidden;
  final List<Task> _taskList;

  List<Task> get taskList {
    return completedIsHidden ? _taskList.where((task) => !task.isCompleted).toList() : _taskList;
  }

  TaskListState(this.completedIsHidden, this._taskList);

}
