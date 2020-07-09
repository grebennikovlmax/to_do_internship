import 'package:todointernship/model/task.dart';

abstract class TaskDetailPageState {}

class LoadedTaskDetailPageState implements TaskDetailPageState {
  final Task task;

  LoadedTaskDetailPageState(this.task);
}