import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'dart:async';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/widgets/time_picker_dialog.dart';
import 'package:todointernship/widgets/custom_fab.dart';
import 'package:todointernship/pages/task_detail_page/steps_card.dart';
import 'package:todointernship/pages/task_detail_page/fab_state.dart';
import 'package:todointernship/widgets/new_task_dialog.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';




class TaskDetail extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return _TaskDetailState();
  }

}

enum _TaskDetailPopupMenuItem {update, delete}

class _TaskDetailState extends State<TaskDetail> {

  final double appBarHeight = 128;
  DateFormat dateFormatter = DateFormat("dd.MM.yyyy");

  ScrollController _scrollController;
  StreamController<FabState> _fabStateStream;
  StreamController<List<TaskStep>> _stepListStreamController;

  ValueNotifier<DateTime> _dateNotifier;
  ValueNotifier<String> _titleNameNotifier;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabStateStream = StreamController();
    _stepListStreamController = StreamController();

    _dateNotifier = ValueNotifier(DateTime.now());
    _titleNameNotifier = ValueNotifier("sd");

    _scrollController.addListener(() {
      final state = FabState(_scrollController.offset, TaskInfo.of(context).task.isCompleted);
      _fabStateStream.add(state);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabStateStream.close();
    _stepListStreamController.close();
    _dateNotifier.dispose();
    _titleNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: TaskInfo.of(context).theme.primaryColor,
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
                  _PopupMenu(onSelected: _popupMenuButtonPressed)
                ],
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                    Card(
                      margin: EdgeInsets.fromLTRB(16, 28, 16, 10),
                      child: StreamBuilder<List<TaskStep>>(
                        initialData: TaskInfo.of(context).task.steps,
                        stream: _stepListStreamController.stream,
                        builder: (context, snapshot) {
                          return StepsCard(snapshot.data, _stepListStreamController.sink);
                        }
                      ),
                    ),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _dateNotifier,
                      builder: (context, value, _) {
                        return _DateNotificationCard(
                          onPickDate: _pickFinalDate,
                          finalDate: dateFormatter.format(value),
                          onNotification: _setNotification,
                        );
                      },
                    )
                  ])
              ),
            ]),
        StreamBuilder<FabState>(
          initialData: FabState(0, false),
          stream: _fabStateStream.stream,
          builder: (context, snapshot) {
            return CustomFloatingButton(snapshot.data.isCompleted, snapshot.data.offset, appBarHeight, _fabPressed );
          }
        )]
      );
  }

  void _fabPressed() {
    final task = TaskInfo.of(context).task;
    TaskInfo.of(context).taskEventSink.add(OnCompletedTask(task));
    final state = FabState(_scrollController.offset, !task.isCompleted);
    _fabStateStream.add(state);
  }

  Future<void> _updateTaskName() async {
    var task = await showDialog<Task>(
        context: context,
        builder: (BuildContext context) {
          return NewTaskDialog();
        }
    );
    if(task != null) {
//      widget.task.name = task.name;
//      widget.task.finalDate = task.finalDate;
//      _dateNotifier.value = task.finalDate;
//      _titleNameNotifier.value = task.name;
    }
  }

  Future<void> _pickFinalDate() async {
    var date = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return TimePickerDialog(withTime: false);
      }
    );

    if(date != null) {
      Task task = TaskInfo.of(context).task;
      task.finalDate = date;
      await TaskDatabaseRepository.shared.updateTask(task);
      _dateNotifier.value = date;
    }
  }

  Future<void> _setNotification() async {
    var dateTime = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return TimePickerDialog(withTime: true);
      }
    );

    if(dateTime != null) {
      final platform = PlatformNotificationChannel();
      Task task = TaskInfo.of(context).task;
      task.notificationDate = dateTime;
      await TaskDatabaseRepository.shared.updateTask(task);
      var res = await platform.setNotification(task);
    }
  }

  _popupMenuButtonPressed(_TaskDetailPopupMenuItem item) {
      switch (item) {
        case _TaskDetailPopupMenuItem.delete:
          TaskDatabaseRepository.shared.removeTask(TaskInfo.of(context).task.id);
          Navigator.of(context).pop();
          break;
        case _TaskDetailPopupMenuItem.update:
          _updateTaskName();
          break;
      }
    }
  }
  
class _DateNotificationCard extends StatelessWidget {
  
  final VoidCallback onPickDate;
  final String finalDate;
  final VoidCallback onNotification;
  
  _DateNotificationCard({this.onPickDate, this.finalDate, this.onNotification});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            onTap: onNotification,
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
            onTap: onPickDate,
            title: finalDate == null ? Text("Добавить дату выполнения")
                  : Text(finalDate),
          )
        ],
      ),
    );
  }
}
  
  
class _PopupMenu extends StatelessWidget {
  
  final PopupMenuItemSelected<_TaskDetailPopupMenuItem> onSelected;

  _PopupMenu({this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TaskDetailPopupMenuItem>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<_TaskDetailPopupMenuItem>(
            value: _TaskDetailPopupMenuItem.delete,
            child: Text("Удалить"),
          ),
          PopupMenuItem<_TaskDetailPopupMenuItem>(
            value: _TaskDetailPopupMenuItem.update,
            child: Text("Редактировать"),
          )
        ];
      },
    );
  }
}
