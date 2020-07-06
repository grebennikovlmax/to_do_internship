import 'package:todointernship/model/task.dart';

abstract class TaskListState {}


class FullTaskListState implements TaskListState {

  final List<Task> taskList;

  FullTaskListState(this.taskList);

}

class EmptyListState implements TaskListState {
  final String description;

  EmptyListState(this.description);
}


