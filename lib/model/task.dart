import 'package:flutter/cupertino.dart';

class Task {
  bool isCompleted;
  int id;
  String name;
  DateTime createdDate;
  DateTime finalDate;
  List<TaskStep> steps = [];
  
  Task({@required this.id, this.name, this.finalDate, this.steps = const [], this.createdDate, this.isCompleted = false}) {
    createdDate ??= DateTime.now();
  }
}

class TaskStep {
  String description;
  bool isCompleted = false;

  TaskStep(this.description);
}