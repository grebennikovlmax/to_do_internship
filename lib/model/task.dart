class Task {
  bool isCompleted = false;
  String name;
  List<TaskStep> steps = [];
  int get stepsCount => steps.length;
  Task(this.name);
}

class TaskStep {
  String description;
  bool isCompleted = false;

  TaskStep(this.description);
}