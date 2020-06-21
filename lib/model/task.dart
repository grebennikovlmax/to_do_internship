class Task {
  bool isCompleted = false;
  String name;
  DateTime createdDate;
  DateTime finalDate;
  List<TaskStep> steps = [];
  int get stepsCount => steps.length;
  int get completedSteps => steps.where((step) => step.isCompleted).length;
  
  Task(this.name) {
    createdDate = DateTime.now();
  }
}

class TaskStep {
  String description;
  bool isCompleted = false;

  TaskStep(this.description);
}