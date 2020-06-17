import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/task_detail_scroll.dart';



class TaskDetail extends StatelessWidget {

  final Task task;
  TaskDetail(this.task);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
      body: TaskDetailScrollView(task)
    );
  }

}

