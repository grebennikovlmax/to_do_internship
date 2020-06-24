class Task {
  bool isCompleted;
  int id;
  String name;
  DateTime createdDate;
  DateTime finalDate;
  List<TaskStep> steps;

  Task({this.id, this.name, this.finalDate, this.createdDate, this.isCompleted = false, this.steps = const []}) {
    createdDate ??= DateTime.now();
  }
}

class TaskStep {
  String description;
  bool isCompleted;
  int id;
  int taskID;

  TaskStep({this.description, this.isCompleted = false, this.id, this.taskID});
}