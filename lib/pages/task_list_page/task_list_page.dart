import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  TaskListPage(this.category);


  @override
  State<StatefulWidget> createState() {
    return _TaskListPageState();
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
    return FutureBuilder<TaskListPageState>(
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
    );
  }

  Future<TaskListPageState> setPageState() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _completedIsHidden = pref.getBool("is_hidden") ?? false;
    final int backgroundColor = pref.getInt("backgroundColor") ?? 0;
    final int primaryColor = pref.getInt("primaryColor") ?? 0;
    final theme = ThemeData(
      backgroundColor: Color(backgroundColor),
      primaryColor: Color(primaryColor)
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

  void _deleteCompletedTask() {
    final incompletedTask = widget.category.tasks.where((task) => !task.isCompleted).toList();
    widget.category.tasks = incompletedTask;
//    _taskListStateStreamController.add(TaskListState(_hideCompletedNotifier.value ,incompletedTask));
  }

  void _hideCompleted() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('is_hidden', !_completedIsHidden);
    setState(() {});
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
  }

  void _onRemoveTask(Task task) async{
    TaskDatabaseRepository.shared.removeTask(task);
    final state = await setTaskListState();
    _taskListStateStreamController.add(state);
  }

  void _onUpdateTask() {
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
