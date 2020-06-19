import 'dart:async';

import 'package:flutter/material.dart';
import 'model/task.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {

  final List<Task> tasks;
  final Sink _tasksSink;

  TaskList(this.tasks, this._tasksSink);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: tasks.length,
        padding: EdgeInsets.all(10),
        separatorBuilder: (BuildContext context, int index) => Divider(height: 4),
        itemBuilder: (context, index) {
          return TaskItem(tasks[index]);
        });
  }

}