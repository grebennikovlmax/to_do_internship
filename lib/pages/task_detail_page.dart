import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:async';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/task_event.dart';
import 'package:todointernship/new_task_dialog.dart';
import 'package:todointernship/time_picker_dialog.dart';
import 'package:todointernship/widgets/sliver_app_bar_fab.dart';
import 'package:todointernship/widgets/steps_card.dart';
import 'package:todointernship/model/fab_state.dart';
import 'package:todointernship/model/category_theme.dart';

class TaskDetailArguments {
  final Task task;
  final CategoryTheme theme;
  final Sink taskEventSink;

  TaskDetailArguments(this.theme, this.task, this.taskEventSink);
}

class TaskDetailPage extends StatefulWidget {

  final TaskDetailArguments arguments;



  TaskDetailPage({this.arguments});

  @override
  State<StatefulWidget> createState() {
    return _TaskDetailPageState(
      taskEventSink: arguments.taskEventSink,
      task: arguments.task,
      theme: arguments.theme
    );
  }

}

enum TaskDetailPopupMenuItem {update, delete}

class _TaskDetailPageState extends State<TaskDetailPage> {

  final Task task;
  final Sink taskEventSink;
  final CategoryTheme theme;

  _TaskDetailPageState({this.task,this.taskEventSink, this.theme});

  double appBarHeight = 128;
  DateFormat dateFormatter = DateFormat("dd.MM.yyyy");

  ScrollController _scrollController;
  StreamController<FabState> _fabStateStreamController;
  StreamController<List<TaskStep>> _stepListStreamController;

  ValueNotifier<DateTime> _dateNotifier;
  ValueNotifier<String> _titleNameNotifier;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabStateStreamController = StreamController();
    _stepListStreamController = StreamController();

    _dateNotifier = ValueNotifier(task.finalDate);
    _titleNameNotifier = ValueNotifier(task.name);


    _scrollController.addListener(() {
      final state = FabState(_scrollController.offset, task.isCompleted);
      _fabStateStreamController.add(state);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabStateStreamController.close();
    _stepListStreamController.close();
    _dateNotifier.dispose();
    _titleNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Color(theme.primaryColor),
                  pinned: true,
                  expandedHeight: appBarHeight,
                  flexibleSpace: FlexibleSpaceBar(
                      title: ValueListenableBuilder<String>(
                        valueListenable: _titleNameNotifier,
                        builder: (context, value, _) {
                          return Text(value);
                        }
                      )),
                  actions: <Widget>[
                    _PopupMenu(
                      onSelected: _popupMenuButtonPressed,
                    )
                  ],
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                      Card(
                        margin: EdgeInsets.fromLTRB(16, 28, 16, 10),
                        child: StreamBuilder<List<TaskStep>>(
                          initialData: task.steps,
                          stream: _stepListStreamController.stream,
                          builder: (context, snapshot) {
                            task.steps = snapshot.data;
                            return StepsCard(snapshot.data, task.createdDate, _stepListStreamController.sink);
                          }
                        ),
                      ),
                      ValueListenableBuilder<DateTime>(
                        valueListenable: _dateNotifier,
                        builder: (context, value, _) {
                          return _DateNotificationCard(
                            onTap: _pickDate,
                            date: dateFormatter.format(value),
                          );
                        },
                      )
                    ])
                ),
              ]),
          StreamBuilder<FabState>(
            initialData: FabState(0, task.isCompleted),
            stream: _fabStateStreamController.stream,
            builder: (context, snapshot) {
              return SliverAppBarFloatingButton(snapshot.data.isCompleted, snapshot.data.offset, appBarHeight, _fabPressed );
            }
          )]
        ),
    );
  }

  void _fabPressed() {
    taskEventSink.add(OnCompletedTask(task));
    final state = FabState(_scrollController.offset, !task.isCompleted);
    _fabStateStreamController.add(state);
  }

  Future<void> _updateTaskName() async {
    var task = await showDialog<Task>(
        context: context,
        builder: (BuildContext context) {
          return NewTaskDialog(task: this.task);
        }
    );
    if(task != null) {
      task.name = task.name;
      task.finalDate = task.finalDate;
      _dateNotifier.value = task.finalDate;
      _titleNameNotifier.value = task.name;
    }
  }

  Future<void> _pickDate() async {
    var date = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return TimePickerDialog();
      }
    );

    if(date == null) {
      TargetPlatform platform = Theme.of(context).platform;
      if (platform == TargetPlatform.fuchsia) {
        date = await showCupertinoModalPopup<DateTime>(
            context: context,
            builder: (context) {
              return CupertinoDatePicker(
                initialDateTime: DateTime.now().add(Duration(days: 1)),
                minimumDate: DateTime.now(),
                onDateTimeChanged: (val) => Navigator.of(context).pop(val),
              );
            }
        );
      } else {
        date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100)
        );
      }
    }

    if(date != null) {
      task.finalDate = date;
      _dateNotifier.value = date;
    }
  }

  _popupMenuButtonPressed(TaskDetailPopupMenuItem item) {
      switch (item) {
        case TaskDetailPopupMenuItem.delete:
          taskEventSink.add(OnRemoveTask(task));
          Navigator.of(context).pop();
          break;
        case TaskDetailPopupMenuItem.update:
          _updateTaskName();
          break;
      }
    }
  }

  class _PopupMenu extends StatelessWidget {

    final PopupMenuItemSelected<TaskDetailPopupMenuItem> onSelected;

    _PopupMenu({this.onSelected});


    @override
    Widget build(BuildContext context) {
      return PopupMenuButton<TaskDetailPopupMenuItem>(
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<TaskDetailPopupMenuItem>(
              value: TaskDetailPopupMenuItem.delete,
              child: Text("Удалить"),
            ),
            PopupMenuItem<TaskDetailPopupMenuItem>(
              value: TaskDetailPopupMenuItem.update,
              child: Text("Редактировать"),
            )
          ];
        },
      );
    }
  }


  class _DateNotificationCard extends StatelessWidget {

    final VoidCallback onTap;
    final String date;

    _DateNotificationCard({this.onTap, this.date});

    @override
    Widget build(BuildContext context) {
      return Card(
          margin: EdgeInsets.fromLTRB(16, 10, 16, 5),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.notifications_none),
                    title: Text("Напомнить")
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                ListTile(
                    leading: Icon(Icons.insert_invitation),
                    onTap: onTap,
                    title: date == null ? Text("Добавить дату выполнения")
                        : Text(date)
                )
              ])
      );
    }
  }

