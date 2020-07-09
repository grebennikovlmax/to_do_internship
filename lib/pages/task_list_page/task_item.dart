import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_block.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_bloc.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';
import 'package:todointernship/widgets/custom_checkbox.dart';

class TaskItem extends StatelessWidget {

  final Task task;

  TaskItem({this.task});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10)
            ),
          )
        ),
        Dismissible(
          direction: DismissDirection.endToStart,
          background: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.delete,color: Colors.white,),
            ),
          ),
          onDismissed: (dir) => BlocProvider.of<TaskListPageBloc>(context).add(RemoveTaskEvent(task.id)),
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
                  onChange: () => BlocProvider.of<TaskListPageBloc>(context).add(CompletedTaskEvent(task.id)),
                ),
              )
          ),
        ),
      ],
    );
  }

  void _toStepList(BuildContext context) {
    var injector = Injector.appInstance;
    // ignore: close_sinks
    var bloc = TaskDetailPageBloc(
        task,
        injector.getDependency<TaskRepository>(),
        injector.getDependency<PlatformNotificationChannel>(),
        BlocProvider.of<TaskListPageBloc>(context)
    );
    Navigator.of(context).pushNamed('/task_detail', arguments: bloc)
        .then((value) => BlocProvider.of<TaskListPageBloc>(context).add((UpdateTaskListEvent())));
  }

}

