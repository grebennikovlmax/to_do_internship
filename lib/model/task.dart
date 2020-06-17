class Task {
  bool isCompleted = false;
  String name;
  DateTime date;
  List<TaskStep> steps = [];
  int get stepsCount => steps.length;
  Task(this.name) {
    date = DateTime.now();
  }
}

class TaskStep {
  String description;
  bool isCompleted = false;

  TaskStep(this.description);
}