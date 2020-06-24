import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todointernship/data/shared_prefs_theme.dart';

import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_state.dart';
import 'package:todointernship/widgets/new_task.dart';
import 'package:todointernship/widgets/popup_menu.dart';
import 'package:todointernship/widgets/theme_picker.dart';
import 'package:todointernship/pages/task_list_page/task_list_state.dart';
import 'package:todointernship/data/task_data/task_repository.dart';

class TaskListPage extends StatefulWidget {

  final Category category;
  final prefTheme = SharedPrefTheme();

  TaskListPage(this.category);


  @override
  State<StatefulWidget> createState() {
    return _TaskListPageState();
  }

}

class TaskListInfo extends InheritedWidget {

  final Sink taskEventSink;

  TaskListInfo({this.taskEventSink, Widget child}) : super(child: child);

  static TaskListInfo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskListInfo>();

  @override
  bool updateShouldNotify(TaskListInfo oldWidget) {
    return false;
  }

}

class _TaskListPageState extends State<TaskListPage> {

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
  void dispose() {
    _taskListStateStreamController.close();
    _taskEventStreamController.close();
    _themeStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TaskListInfo(
      taskEventSink: _taskEventStreamController.sink,
      child: FutureBuilder<TaskListPageState>(
        future: setPageState(),
        builder: (context, pageState) {
          if(!pageState.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder<ThemeData>(
            initialData: pageState.data.themeData,
            stream: _themeStreamController.stream,
            builder: (context, snapshot) {
              return Scaffold(
                  backgroundColor: snapshot.data.backgroundColor,
                  appBar: AppBar(
                    title: Text(widget.category.name),
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
                    future: setTaskListState(),
                    builder: (context, future) {
                      if(future.hasError) {
                        print(future.error);
                      }
                      if(!future.hasData) return Container();
                      return StreamBuilder<TaskListState>(
                        initialData: future.data,
                        stream: _taskListStateStreamController.stream,
                        builder: (context, snapshot) {
                          return TaskList(snapshot.data.taskList);
                        },
                      );
                    }
                  ),
                  floatingActionButton: FloatingActionButton(
                      onPressed: newTask,
                      child: Icon(Icons.add)
                  )
              );
            },
          );
        },
      ),
    );
  }

  Future<TaskListPageState> setPageState() async{
    final pref = await SharedPreferences.getInstance();
    _completedIsHidden = pref.getBool("is_hidden") ?? false;
    final categoryTheme = await widget.prefTheme.loadTheme(0);
    final theme = ThemeData(
      backgroundColor: Color(categoryTheme.backgroundColor),
      primaryColor: Color(categoryTheme.primaryColor)
    );
    return TaskListPageState(completedIsHidden: _completedIsHidden, themeData: theme);

  }

  Future<TaskListState> setTaskListState() async {
    final taskList = await TaskDatabaseRepository.shared.getTaskList();
    return TaskListState(
      _completedIsHidden, taskList
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
      var t = await setTaskListState();
      _taskListStateStreamController.add(t);
    }
  }

  void _deleteCompletedTask() async {
    TaskDatabaseRepository.shared.removeCompletedTask();
    final state = await setTaskListState();
    _taskListStateStreamController.add(state);
  }

  void _hideCompleted() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('is_hidden', !_completedIsHidden);
    final state = await setTaskListState();
    _taskListStateStreamController.add(state);
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
    await TaskDatabaseRepository.shared.updateTask(task);
    final state = await setTaskListState();
    _taskListStateStreamController.add(state);
  }

  void _onRemoveTask(Task task) async{
    TaskDatabaseRepository.shared.removeTask(task.id);
    final state = await setTaskListState();
    _taskListStateStreamController.add(state);
  }

  void _onUpdateTask() async {
    final state = await setTaskListState();
    _taskListStateStreamController.add(state);
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
