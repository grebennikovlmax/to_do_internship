abstract class TaskEvent {

}

class CompletedTaskEvent extends TaskEvent {

  int taskId;

  CompletedTaskEvent([this.taskId]);

}

class RemoveTaskEvent extends TaskEvent {

  int taskId;

  RemoveTaskEvent([this.taskId]);

}

class NewTaskEvent implements TaskEvent {
  final DateTime finalDate;
  final DateTime notificationDate;
  final String name;

  NewTaskEvent(this.finalDate, this.notificationDate, this.name);
}

class UpdateTaskNameEvent extends TaskEvent {
  final String name;
  int id;
  UpdateTaskNameEvent(this.name);
}

class RemoveCompletedEvent extends TaskEvent {

}

class UpdateTaskListEvent extends TaskEvent {

}
