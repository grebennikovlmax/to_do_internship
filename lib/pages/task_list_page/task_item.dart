import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list_page.dart';
import 'package:todointernship/widgets/custom_checkbox.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page.dart';


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
      onDismissed: (dir) => TaskListBlocProvider.of(context).bloc.taskEventSink.add(RemoveTaskEvent(task.id)),
      key: ValueKey(task.id),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
          ),
          child: ListTile(
            onTap: () => _toStepList(context),
            title: Text(task.name,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontSize: 18
              ),
            ),
            subtitle: task.steps.isEmpty ? null : Text("${task.completedStep} из ${task.amountSteps}",
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontSize: 18,
                color: const Color(0xff979797)
              ),
            ),
            leading: CustomCheckBox(
              value: task.isCompleted,
              color: Scaffold.of(context).widget.backgroundColor,
              onChange: () => TaskListBlocProvider.of(context).bloc.taskEventSink.add(CompletedTaskEvent(task.id)),
            ),
          )
      ),
    );
  }

  void _toStepList(BuildContext context) {
    Navigator.of(context).pushNamed('/task_detail', arguments: TaskDetailArguments(
      task: task,
    )).then((value) => TaskListBlocProvider.of(context).bloc.taskEventSink.add((UpdateTaskListEvent())));
  }

}

