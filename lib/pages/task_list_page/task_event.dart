import 'package:todointernship/model/task.dart';

abstract class TaskEvent {
  final Task task;
  TaskEvent(this.task);
}

class OnCompletedTask extends TaskEvent {

  OnCompletedTask(Task task) : super(task);

}

class OnRemoveTask extends TaskEvent {

  OnRemoveTask(Task task) : super(task);

}

class OnUpdateTask extends TaskEvent {

  OnUpdateTask(Task task) : super(task);

}
