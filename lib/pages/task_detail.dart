import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/task_detail_scroll.dart';
import 'package:todointernship/model/category_theme.dart';


class TaskDetailArguments {
  final Task task;
  final CategoryTheme theme;
  final Sink taskEvent;

  TaskDetailArguments(this.theme, this.task, this.taskEvent);
}


class TaskDetail extends StatelessWidget {

  final TaskDetailArguments arguments;

  TaskDetail(this.arguments);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(arguments.theme.backgroundColor),
      body: TaskDetailScrollView(arguments.task, arguments.taskEvent, arguments.theme)
    );
  }

}

