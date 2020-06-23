import 'dart:async';

import 'package:flutter/material.dart';


import '../../model/task.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {

  final List<Task> taskList;

  TaskList(this.taskList);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: taskList.length,
        padding: EdgeInsets.all(10),
        separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.transparent,height: 4),
        itemBuilder: (context, index) {
          return  TaskItem(task: taskList[index]);
        }
    );
  }

}
