abstract class TaskCreationEvent {

}

class NewTaskEvent implements TaskCreationEvent {
  final DateTime finalDate;
  final DateTime notificationDate;
  final String name;

  NewTaskEvent(this.finalDate,this.notificationDate,this.name);
}

class EditTaskEvent implements TaskCreationEvent {
  final String name;

  EditTaskEvent(this.name);
}