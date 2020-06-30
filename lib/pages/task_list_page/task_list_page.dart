import 'package:flutter/material.dart';

import 'dart:async';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/empty_task_list.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list.dart';
import 'package:todointernship/widgets/new_task_dialog.dart';
import 'package:todointernship/widgets/popup_menu.dart';
import 'package:todointernship/widgets/theme_picker.dart';
import 'package:todointernship/pages/task_list_page/task_list_state.dart';
import 'package:todointernship/data/task_data/task_repository.dart';

class TaskListPage extends StatefulWidget {

  final String title;

  TaskListPage(this.title);

  @override
  State<StatefulWidget> createState() {
    return _TaskListPageState();
  }

}

class TaskListInfo extends InheritedWidget {

  final Sink taskEventSink;
  static TaskListInfo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskListInfo>();

  TaskListInfo({this.taskEventSink, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(TaskListInfo oldWidget) {
    return false;
  }

}

class _TaskListPageState extends State<TaskListPage> {

  final SharedPrefManager _prefManager = SharedPrefManager();
  final TaskRepository _taskRepository = TaskDatabaseRepository.shared;
  StreamController<TaskListState> _taskListStateStreamController;
  StreamController<TaskEvent> _taskEventStreamController;
  StreamController<ThemeData> _themeStreamController;
  bool _completedIsHidden;


  @override
  void initState() {
    super.initState();
    _taskListStateStreamController = StreamController();
    _taskEventStreamController = StreamController();
    _themeStreamController = StreamController();
    _taskEventStreamController.stream.listen((event) {
      if(event is OnRemoveTask) _onRemoveTask(event.task);
      if(event is OnCompletedTask) _onCompletedTask(event.task);
      if(event is OnUpdateTask) _onUpdateTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TaskListInfo(
      taskEventSink: _taskEventStreamController.sink,
      child: FutureBuilder<ThemeData>(
        future: _getThemeData(),
        builder: (context, future) {
          if(!future.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder<ThemeData>(
            initialData: future.data,
            stream: _themeStreamController.stream,
            builder: (context, snapshot) {
              return Scaffold(
                  backgroundColor: snapshot.data.backgroundColor,
                  appBar: AppBar(
                    title: Text(widget.title),
                    backgroundColor: snapshot.data.primaryColor,
                    actions: <Widget>[
                      PopupMenu(
                        isHidden: _completedIsHidden,
                        onDelete: _deleteCompletedTask,
                        onChangeTheme: _changeTheme,
                        onHide: _hideCompleted,
                      )
                    ]
                  ),
                  body: FutureBuilder<TaskListState>(
                    future: _setTaskListState(),
                    builder: (context, future) {
                      if(future.hasError) {
                        print(future.error);
                      }
                      if(!future.hasData) return Container();
                      return StreamBuilder<TaskListState>(
                        initialData: future.data,
                        stream: _taskListStateStreamController.stream,
                        builder: (context, snapshot) {
                          if(snapshot.data is EmptyListState) {
                            return EmptyTaskList();
                          }
                          return TaskList(snapshot.data.taskList);
                        },
                      );
                    }
                  ),
                  floatingActionButton: FloatingActionButton(
                      onPressed: _newTask,
                      child: Icon(Icons.add)
                  )
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _taskListStateStreamController.close();
    _taskEventStreamController.close();
    _themeStreamController.close();
    super.dispose();
  }

  Future<ThemeData> _getThemeData() async{
    final categoryTheme = await _prefManager.loadTheme(0);
    _completedIsHidden = await _prefManager.getHiddenFlag(0);
    if(categoryTheme.backgroundColor == null || categoryTheme.primaryColor == null) {
      return Theme.of(context);
    }
    final theme = ThemeData(
      backgroundColor: Color(categoryTheme.backgroundColor),
      primaryColor: Color(categoryTheme.primaryColor)
    );
    return theme;

  }

  void _newTask() async {
    var task = await showDialog<Task>(
        context: context,
        builder: (BuildContext context) {
          return NewTaskDialog();
        }
    );
    if(task != null) {
      _taskListStateStreamController.add(await _setTaskListState());
    }
  }

  void _deleteCompletedTask() async {
    _taskRepository.removeCompletedTask();
    _taskListStateStreamController.add(await _setTaskListState());
  }

  void _hideCompleted() async{
    _completedIsHidden = !_completedIsHidden;
    await _prefManager.saveHiddenFlag(_completedIsHidden, 0);
    _taskListStateStreamController.add(await _setTaskListState());
    setState(() {

    });
  }

  void _changeTheme(BuildContext context) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return ThemePicker(_themeStreamController.sink);
        });
  }

  void _onCompletedTask(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _taskRepository.updateTask(task);
    _taskListStateStreamController.add(await _setTaskListState());
  }

  void _onRemoveTask(Task task) async{
    _taskRepository.removeTask(task.id);
    _taskListStateStreamController.add(await _setTaskListState());
  }

  void _onUpdateTask() async {
    _taskListStateStreamController.add(await _setTaskListState());
  }

  Future<TaskListState> _setTaskListState() async {
    final taskList = await _taskRepository.getTaskListForCategory(0);
    if(taskList.isEmpty) {
      return EmptyListState();
    }
    return FullTaskListState(taskList);
  }
}
