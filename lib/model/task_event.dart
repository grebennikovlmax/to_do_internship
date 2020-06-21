import 'package:todointernship/model/task.dart';

abstract class TaskEvent {
  final Task task;
  TaskEvent(this.task);
}

class OnCompletedTask implements TaskEvent {

  final Task task;

  OnCompletedTask(this.task);


}

class OnRemoveTask implements TaskEvent {

  final Task task;

  OnRemoveTask(this.task);

}

class OnUpdateTask implements TaskEvent {

  final Task task;

  OnUpdateTask(this.task);

}
