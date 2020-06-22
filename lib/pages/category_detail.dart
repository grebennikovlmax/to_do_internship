import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todointernship/empty_task_list.dart';
import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/task_event.dart';
import 'package:todointernship/task_list.dart';
import 'package:todointernship/new_task.dart';
import 'package:todointernship/popup_menu.dart';
import 'package:todointernship/theme_picker.dart';
import 'package:todointernship/model/task_list_state.dart';

class CategoryDetail extends StatefulWidget {

  final Category category;

  CategoryDetail(this.category);


  @override
  State<StatefulWidget> createState() {
    return _CategoryDetailState();
  }

}

class CategoryInfo extends InheritedWidget {

  final Category category;
  final Sink taskEventSink;

  CategoryInfo({this.category, this.taskEventSink, Widget child}) : super(child: child);

  static CategoryInfo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CategoryInfo>();

  @override
  bool updateShouldNotify(CategoryInfo oldWidget) {
    return oldWidget.category != category;
  }

}

class _CategoryDetailState extends State<CategoryDetail> {

  StreamController<TaskListState> _taskListStateStreamController;
  ValueNotifier<bool> _hideCompletedNotifier;
  StreamController<TaskEvent> _taskEventStreamController;
  StreamController<ThemeData> _themeStreamController;

  @override
  void initState() {
    super.initState();
    _taskListStateStreamController = StreamController();
    _hideCompletedNotifier = ValueNotifier(false);
    _taskEventStreamController = StreamController();
    _themeStreamController = StreamController();

    _taskEventStreamController.stream.listen((event) {
      if(event is OnRemoveTask) _onRemoveTask(event.task);
      if(event is OnCompletedTask) _onCompletedTask(event.task);
      if(event is OnUpdateTask) _onUpdateTask();
    });
  }

  @override
  void dispose() {
    _taskListStateStreamController.close();
    _taskEventStreamController.close();
    _hideCompletedNotifier.dispose();
    _themeStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeData>(
      initialData: ThemeData(
        backgroundColor: Color(widget.category.theme.backgroundColor),
        primaryColor: Color(widget.category.theme.primaryColor)
      ),
      stream: _themeStreamController.stream,
      builder: (context, snapshot) {
        widget.category.theme = CategoryTheme(snapshot.data.backgroundColor.value, snapshot.data.primaryColor.value);
        return Scaffold(
          backgroundColor: snapshot.data.backgroundColor,
          appBar: AppBar(
            title: Text(widget.category.name),
            backgroundColor: snapshot.data.primaryColor,
            actions: <Widget>[
              ValueListenableBuilder<bool>(
                valueListenable: _hideCompletedNotifier,
                builder: (context, value, _) {
                  return Builder(
                    builder: (context) {
                     return PopupMenu(
                      isHidden: value,
                      onDelete: _deleteCompletedTask,
                      onChangeTheme: () => _changeTheme(context),
                      onHide: _hideCompleted,
                     );
                    }
                  );
                }
              )
            ],
          ),
          body: CategoryInfo(
            category: widget.category,
            taskEventSink: _taskEventStreamController.sink,
            child: StreamBuilder<TaskListState>(
              stream: _taskListStateStreamController.stream,
              initialData: TaskListState(_hideCompletedNotifier.value, widget.category.tasks),
              builder: (context, snapshot) {
                if(snapshot.data.completedIsHidden && snapshot.data.taskList.isEmpty && widget.category.tasks.isNotEmpty) {
                  return EmptyTaskList(isEmptyTask: false);
                }
                if(snapshot.data.taskList.isEmpty) {
                  return EmptyTaskList(isEmptyTask: true);
                }
                return TaskList(snapshot.data.taskList);
              }
              )
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: newTask,
            child: Icon(Icons.add)
          )
        );
      }
    );
  }

  void newTask() async {
    var task = await showDialog<Task>(
        context: context,
        builder: (BuildContext context) {
          return NewTask();
        }
    );
    if(task != null) {
      widget.category.tasks.add(task);
      _taskListStateStreamController.add(TaskListState(_hideCompletedNotifier.value ,widget.category.tasks));
    }
  }

  void _deleteCompletedTask() {
    final incompletedTask = widget.category.tasks.where((task) => !task.isCompleted).toList();
    widget.category.tasks = incompletedTask;
    _taskListStateStreamController.add(TaskListState(_hideCompletedNotifier.value ,incompletedTask));
  }

  void _hideCompleted() {
    _hideCompletedNotifier.value = !_hideCompletedNotifier.value;
    final state = TaskListState(_hideCompletedNotifier.value, widget.category.tasks);
    _taskListStateStreamController.add(state);
  }

  void _changeTheme(BuildContext context) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return ThemePicker(_themeStreamController.sink);
        });
  }

  void _onCompletedTask(Task task) {
    final index = widget.category.tasks.indexWhere((element) => element.name == task.name);
    widget.category.tasks[index].isCompleted = !widget.category.tasks[index].isCompleted;
    _taskListStateStreamController.add(TaskListState(_hideCompletedNotifier.value, widget.category.tasks));
  }

  void _onRemoveTask(Task task) {
    widget.category.tasks.remove(task);
    _taskListStateStreamController.add(TaskListState(_hideCompletedNotifier.value, widget.category.tasks));
  }

  void _onUpdateTask() {
    _taskListStateStreamController.add(TaskListState(_hideCompletedNotifier.value, widget.category.tasks));
  }


}
