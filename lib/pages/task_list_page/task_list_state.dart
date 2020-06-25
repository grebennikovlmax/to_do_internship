import 'package:todointernship/model/task.dart';

abstract class TaskListState {

  final List<Task> taskList;

  TaskListState(this.taskList);

}


class FullTaskListState implements TaskListState {

  final List<Task> taskList;

  FullTaskListState(this.taskList);

}

class EmptyListState implements TaskListState {

  List<Task> get taskList => [];

}

