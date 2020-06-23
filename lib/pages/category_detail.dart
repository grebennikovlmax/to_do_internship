import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/task_event.dart';
import 'package:todointernship/task_list.dart';
import 'package:todointernship/new_task.dart';
import 'package:todointernship/popup_menu.dart';
import 'package:todointernship/theme_picker.dart';
import 'package:todointernship/model/task_list_state.dart';
import 'package:todointernship/data/task_repository.dart';

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
  StreamController<Future<ThemeData>> _themeStreamController;
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
    return StreamBuilder(
      initialData: _getTheme(),
      stream: _themeStreamController.stream,
      builder: (context, snapshot) {
          return FutureBuilder<ThemeData>(
            future: snapshot.data,
            builder: (context, future) {
              if(!future.hasData) return Container();
              return Scaffold(
                backgroundColor: future.data.backgroundColor,
                appBar: AppBar(
                  title: Text(widget.category.name),
                  backgroundColor: future.data.primaryColor,
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
                  child: FutureBuilder(
                    future: MockTaskRepository.shared.getTaskList(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return TaskList(snapshot.data);
                    },
                  ),
//            child: StreamBuilder<TaskListState>(
//              stream: _taskListStateStreamController.stream,
//              initialData: TaskListState(_hideCompletedNotifier.value, widget.category.tasks),
//              builder: (context, snapshot) {
//                if(snapshot.data.completedIsHidden && snapshot.data.taskList.isEmpty && widget.category.tasks.isNotEmpty) {
//                  return EmptyTaskList(isEmptyTask: false);
//                }
//                if(snapshot.data.taskList.isEmpty) {
//                  return EmptyTaskList(isEmptyTask: true);
//                }
//                return TaskList(snapshot.data.taskList);
//              }
//              )
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: newTask,
                  child: Icon(Icons.add)
                )
              );
            }
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

  Future<ThemeData> _getTheme() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final int backgroundColor = pref.getInt("backgroundColor") ?? 0;
    final int primaryColor = pref.getInt("primaryColor") ?? 0;
    return ThemeData(
        backgroundColor: Color(backgroundColor),
        primaryColor: Color(primaryColor)
    );
}


}
