import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todointernship/model/task_event.dart';
import 'package:todointernship/pages/category_detail.dart';
import 'model/task.dart';
import 'task_item.dart';


class TaskListInfo extends InheritedWidget {

  final List<Task> tasks;

  TaskListInfo({Widget child, this.tasks}) : super(child: child);

  @override
  bool updateShouldNotify(TaskListInfo oldWidget) {
    return oldWidget.tasks != tasks;
  }

}


class TaskList extends StatefulWidget {

  final List<Task> tasks;

  TaskList(this.tasks);

  @override
  State<StatefulWidget> createState() {
    return _TaskListState();
  }
}

class _TaskListState extends State<TaskList> {

  StreamController<TaskEvent> _eventStreamController;
  StreamController<List<Task>> _taskListStreamController;

  @override
  void initState() {
    super.initState();
    _eventStreamController = StreamController();
    _eventStreamController.stream.listen((event) {
      if(event is OnRemoveTask) onRemoveTask(event.task);
      if(event is OnCompletedTask) onCompletedTask(event.task);
      if(event is  OnUpdateTask) onUpdateTask();
    });
    _taskListStreamController = StreamController();
  }

  @override
  void dispose() {
    _eventStreamController.close();
    _taskListStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: widget.tasks,
        stream: _taskListStreamController.stream,
        builder: (context, snapshot) {
          return ListView.separated(
            itemCount: widget.tasks.length,
            padding: EdgeInsets.all(10),
            separatorBuilder: (BuildContext context, int index) => Divider(height: 4),
            itemBuilder: (context, index) {
              return  TaskItem(task: snapshot.data[index], sink: _eventStreamController.sink);
            }
        );
      }
    );
  }

  void onCompletedTask(Task task) {
    final index = widget.tasks.indexWhere((element) => element.name == task.name);
    widget.tasks[index].isCompleted = !widget.tasks[index].isCompleted;
    _taskListStreamController.add(widget.tasks);
  }

  void onRemoveTask(Task task) {
    widget.tasks.remove(task);
    CategoryInfo.of(context).taskListSink.add(widget.tasks);
  }

  void onUpdateTask() {
    CategoryInfo.of(context).taskListSink.add(widget.tasks);
  }


}