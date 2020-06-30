import 'package:flutter/material.dart';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/task_detail.dart';


class TaskDetailArguments {

  final Task task;
  final Sink taskEventSink;

  TaskDetailArguments({this.task, this.taskEventSink});
}

class TaskInfo extends InheritedWidget {

  final Task task;
  final Sink taskEventSink;
  final ThemeData theme;
  static TaskInfo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskInfo>();

  TaskInfo({this.task, this.taskEventSink, this.theme, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

}



class TaskDetailPage extends StatelessWidget {

  final TaskDetailArguments arguments;
  final prefTheme = SharedPrefManager();

  TaskDetailPage(this.arguments);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
      future: _getTheme(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return TaskInfo(
          taskEventSink: arguments.taskEventSink,
          theme: snapshot.data,
          task: arguments.task,
            child: Scaffold(
            backgroundColor: snapshot.data.backgroundColor,
              body: TaskDetail()
            )
        );
      }
    );
  }

  Future<ThemeData> _getTheme() async {
    final categoryTheme = await prefTheme.loadTheme(0);
    return ThemeData(
      backgroundColor: Color(categoryTheme.backgroundColor ?? 0),
      primaryColor: Color(categoryTheme.primaryColor ?? 0)
    );
  }

}

