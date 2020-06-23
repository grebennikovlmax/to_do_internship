import 'package:flutter/material.dart';

import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/widgets/custom_checkbox.dart';
import 'package:todointernship/pages/task_list_page/task_list_page.dart';
import 'package:todointernship/pages/task_detail_page/task_detail.dart';


class TaskItem extends StatelessWidget {

  final Task task;

  TaskItem({this.task});

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
        CategoryInfo.of(context).taskEventSink.add(OnRemoveTask(task))
      },
      key: ValueKey(task.id),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
          ),
          child: ListTile(
            onTap: () => Navigator.of(context).pushNamed('/task_detail',arguments:
            TaskDetailArguments(
                CategoryInfo.of(context).category.theme,
                task,
                CategoryInfo.of(context).taskEventSink)
            ).then((value) => CategoryInfo.of(context).taskEventSink.add(OnUpdateTask(task))),
            title: Text(task.name),
//            subtitle: task.stepsCount == 0 ? null : Text("${task.completedSteps} из ${task.stepsCount}"),
            leading: CustomCheckBox(
              value: task.isCompleted,
              color: Scaffold.of(context).widget.backgroundColor,
              onChange: () {
                CategoryInfo.of(context).taskEventSink.add(OnCompletedTask(task));
              },
            ),
          )
      ),
    );
  }

}

