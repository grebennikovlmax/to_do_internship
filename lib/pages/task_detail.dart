import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/task_detail_scroll_view.dart';
import 'package:todointernship/model/category_theme.dart';


class TaskDetailArguments {
  final Task task;
  final CategoryTheme theme;
  final Sink taskEventSink;

  TaskDetailArguments(this.theme, this.task, this.taskEventSink);
}


class TaskDetail extends StatelessWidget {

  final TaskDetailArguments arguments;

  TaskDetail(this.arguments);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(arguments.theme.backgroundColor),
      body: TaskDetailScrollView(arguments.task, arguments.taskEventSink, arguments.theme)
    );
  }

}

