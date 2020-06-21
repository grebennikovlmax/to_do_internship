import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todointernship/empty_task_list.dart';
import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/task_list.dart';
import 'package:todointernship/new_task.dart';
import 'package:todointernship/popup_menu.dart';
import 'package:todointernship/theme_picker.dart';

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
  final Sink taskListSink;

  CategoryInfo({this.category, this.taskListSink, Widget child}) : super(child: child);

  static CategoryInfo of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CategoryInfo>();

  @override
  bool updateShouldNotify(CategoryInfo oldWidget) {
    return oldWidget.category != category;
  }

}

class _CategoryDetailState extends State<CategoryDetail> {

  StreamController<List<Task>> _streamController;
  bool _isCompletedHidden = false;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.category.theme.backgroundColor),
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Color(widget.category.theme.primaryColor),
        actions: <Widget>[
          PopupMenu(
            isHidden: false,
            onDelete: _deleteCompletedTask,
            onChangeTheme: _changeTheme,
            onHide: () {},
          )
        ],
      ),
      body: CategoryInfo(
        category: widget.category,
        taskListSink: _streamController.sink,
        child: StreamBuilder<List<Task>>(
          stream: _streamController.stream,
          initialData: widget.category.tasks,
          builder: (context, snapshot) {
            if(snapshot.data.isEmpty) {
              return EmptyTaskList(isEmptyTask: true);
            }
            widget.category.tasks = snapshot.data;
            return TaskList(snapshot.data);
          }
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newTask,
        child: Icon(Icons.add)
      )
    );
  }

  void newTask() async {
    var todo = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return NewTask("Новое Задание");
        }
    );
    if(todo != null) {
      widget.category.tasks.add(Task(todo));
      _streamController.add(widget.category.tasks);
    }
  }

  void _deleteCompletedTask() {
    final incompletedTask = widget.category.tasks.where((task) => !task.isCompleted).toList();
    _streamController.add(incompletedTask);
  }

  void _changeTheme() {
    showBottomSheet(
        context: context,
        builder: (context) {
          return ThemePicker(
            ThemeData(
              primaryColor: Colors.purple[500],
              backgroundColor: Colors.purple[200],
            ),
              (val) => {},
          );
        });
  }


}
