import 'package:flutter/material.dart';

import 'package:todointernship/model/task_event.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/custom_checkbox.dart';
import 'package:todointernship/pages/task_detail.dart';


class TaskItem extends StatelessWidget {

  final Task task;
  final Sink sink;

  TaskItem({this.task, this.sink});

  @override
  Widget build(BuildContext context) {
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
        sink.add(OnRemoveTask(task))
      },
      key: UniqueKey(),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
          ),
          child: ListTile(
            onTap: () => Navigator.of(context).pushNamed('/task_detail',arguments: TaskDetailArguments(sink, task))
                .then((value) => sink.add(OnUpdateTask(task))),
            title: Text(task.name),
            subtitle: task.stepsCount == 0 ? null : Text("${task.completedSteps} из ${task.stepsCount}"),
            leading: CustomCheckBox(
              value: task.isCompleted,
              onChange: () {
                sink.add(OnCompletedTask(task));
              },
            ),
          )
      ),
    );
  }

}

