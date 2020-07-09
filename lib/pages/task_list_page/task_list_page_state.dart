import 'package:todointernship/model/task.dart';

abstract class TaskListPageState {}

abstract class LoadedTaskListPageState {
  final int categoryId;
  final bool isHidden;
  final String title;

  LoadedTaskListPageState(this.isHidden, this.categoryId, this.title);
}

class LoadingTaskListPageState implements TaskListPageState {}

class NotEmptyTaskListPageState extends LoadedTaskListPageState implements TaskListPageState {

  final List<Task> taskList;

  NotEmptyTaskListPageState(bool isHidden, int categoryId, String title, this.taskList) : super(isHidden, categoryId, title);

}

class EmptyTaskListPageState extends LoadedTaskListPageState implements TaskListPageState {

  final String description;

  EmptyTaskListPageState(bool isHidden, int categoryId, String title, this.description) : super(isHidden, categoryId, title);

}