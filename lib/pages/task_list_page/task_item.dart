import 'package:flutter/material.dart';

import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/widgets/custom_checkbox.dart';
import 'package:todointernship/pages/task_list_page/task_list_page.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page.dart';


class TaskItem extends StatelessWidget {

  final Task task;

  TaskItem({this.task});

  @override
  Widget build(BuildContext context) {
    final int stepsCount = task.steps.length;
    final int completedStepsCount = task.steps.where((element) => element.isCompleted).length;
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.delete,color: Colors.white,),
          ),
        ),
      ),
      onDismissed: (dir) => {
        TaskListInfo.of(context).taskEventSink.add(OnRemoveTask(task))
      },
      key: ValueKey(task.id),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
          ),
          child: ListTile(
            onTap: () => Navigator.of(context).pushNamed('/task_detail',
                arguments: TaskDetailArguments(
                  task: task,
                  taskEventSink: TaskListInfo.of(context).taskEventSink
                )
              ).then((value) => TaskListInfo.of(context).taskEventSink.add(OnUpdateTask(task))),
            title: Text(task.name),
            subtitle: task.steps.isEmpty ? null : Text("$completedStepsCount из $stepsCount"),
            leading: CustomCheckBox(
              value: task.isCompleted,
              color: Scaffold.of(context).widget.backgroundColor,
              onChange: () {
                TaskListInfo.of(context).taskEventSink.add(OnCompletedTask(task));
              },
            ),
          )
      ),
    );
  }

}

