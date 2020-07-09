import 'package:flutter/material.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/task_item.dart';

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
