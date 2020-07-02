abstract class TaskEvent {

}

class CompletedTaskEvent extends TaskEvent {
  final int taskId;

  CompletedTaskEvent(this.taskId);

}

class RemoveTaskEvent extends TaskEvent {
  final int taskId;

  RemoveTaskEvent(this.taskId);

}

class UpdateTaskEvent extends TaskEvent {

}

class RemoveCompletedEvent extends TaskEvent {

}

class UpdateTaskListEvent extends TaskEvent {

}
