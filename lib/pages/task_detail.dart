import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/task_detail_scroll.dart';

class TaskDetailArguments {
  final Task task;
  final Sink taskEvent;

  TaskDetailArguments(this.taskEvent, this.task);
}


class TaskDetail extends StatelessWidget {

  final TaskDetailArguments arguments;

  TaskDetail(this.arguments);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: TaskDetailScrollView(arguments.task,arguments.taskEvent)
    );
  }

}

