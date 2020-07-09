abstract class TaskEvent {}

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
  UpdateTaskNameEvent(this.name);
}

class UpdateTaskFinalDateEvent extends TaskEvent {

  final DateTime newDate;

  UpdateTaskFinalDateEvent(this.newDate);
}

class UpdateTaskNotificationDateEvent extends TaskEvent {
  final DateTime newDate;

  UpdateTaskNotificationDateEvent(this.newDate);
}

class RemoveCompletedEvent extends TaskEvent {}

class UpdateTaskListEvent extends TaskEvent {}

class HideTaskEvent extends TaskEvent {}