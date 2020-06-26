import 'package:flutter/material.dart';

import 'dart:async';

import 'package:intl/intl.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/task_image.dart';
import 'package:todointernship/pages/task_detail_page/date_state.dart';
import 'package:todointernship/pages/task_detail_page/photo_list.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/widgets/time_picker_dialog.dart';
import 'package:todointernship/widgets/sliver_app_bar_fab.dart';
import 'package:todointernship/pages/task_detail_page/steps_card.dart';
import 'package:todointernship/pages/task_detail_page/fab_state.dart';
import 'package:todointernship/widgets/new_task_dialog.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';
import 'package:todointernship/data/task_data/task_repository.dart';

class TaskDetail extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _TaskDetailState();
  }

}

enum _TaskDetailPopupMenuItem {update, delete}

class _TaskDetailState extends State<TaskDetail> {

  final double appBarHeight = 128;
  ScrollController _scrollController;
  StreamController<FabState> _fabStateStream;
  StreamController<List<TaskStep>> _stepListStreamController;
  StreamController<DateState> _dateStateStreamController;
  StreamController<Future<List<TaskImage>>> _imageStreamController;
  ValueNotifier<String> _titleNameNotifier;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabStateStream = StreamController();
    _stepListStreamController = StreamController();
    _dateStateStreamController = StreamController();
    _imageStreamController = StreamController();
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
    _dateStateStreamController.close();
    _stepListStreamController.close();
    _titleNameNotifier.dispose();
    _imageStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: _scrollController,
            slivers: <Widget>[
              ValueListenableBuilder<String>(
                valueListenable: _titleNameNotifier,
                builder: (context, value, _) {
                  return _TaskDetailSliverAppBar(
                    title: value,
                    onSelected: _popupMenuButtonPressed,
                    height: appBarHeight,
                  );
                }
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
                    StreamBuilder<DateState>(
                      stream: _dateStateStreamController.stream,
                      initialData: _getDateState(),
                      builder: (context, snapshot) {
                        return _DateNotificationCard(
                          onPickDate: _pickFinalDate,
                          finalDate: snapshot.data.finalDate,
                          notificationDate: snapshot.data.notificationDate,
                          onNotification: _setNotification,
                        );
                      },
                    ),
                    Divider(color: Colors.transparent, height: 30),
                    StreamBuilder<Future<List<TaskImage>>>(
                      stream: _imageStreamController.stream,
                      initialData: _loadImages(),
                      builder: (context, snapshot) {
                        return PhotoList(
                          onDelete: _deleteImage ,
                          imageList: snapshot.data,
                          onPickPhoto: _onPickPhoto,
                        );
                      }
                    )
                  ])
              ),
            ]),
        StreamBuilder<FabState>(
          initialData: FabState(0, false),
          stream: _fabStateStream.stream,
          builder: (context, snapshot) {
            return SliverAppBarFab(snapshot.data.isCompleted, snapshot.data.offset, appBarHeight, _fabPressed );
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

  Future<void> _onPickPhoto() async {
    final url = await Navigator.pushNamed(context, '/photo_picker');
    if(url != null) {
      final int taskId = TaskInfo.of(context).task.id;
      await TaskDatabaseRepository.shared.saveImage(url: url, taskId: taskId);
      _imageStreamController.add(_loadImages());
    }
  }

  Future<List<TaskImage>> _loadImages() async {
    final task = TaskInfo.of(context).task;
    final imageList = await TaskDatabaseRepository.shared.fetchImagesForTask(task.id);
    return imageList;
  }

  Future<void> _deleteImage(String path) async {
    final res = await TaskDatabaseRepository.shared.removeImage(path);
    _imageStreamController.add(_loadImages());
  }

  Future<void> _updateTaskName() async {
    final task = TaskInfo.of(context).task;
    final updatedTask = await showDialog<Task>(
        context: context,
        builder: (BuildContext context) {
          return NewTaskDialog(task: task);
        }
    );
    if(updatedTask != null) {
      task.name = updatedTask.name;
      task.finalDate = updatedTask.finalDate;
      task.notificationDate = updatedTask.notificationDate;
      await TaskDatabaseRepository.shared.updateTask(task);
      _titleNameNotifier.value = task.name;
      _dateStateStreamController.add(_getDateState());
    }
  }

  DateState _getDateState() {
    DateFormat dateFormatter = DateFormat("dd.MM.yyyy");
    DateFormat dateTimeFormatter = DateFormat("dd.MM.yyyy H:mm");
    final task = TaskInfo.of(context).task;
    final finalDateString = task.finalDate == null ? null : dateFormatter.format(task.finalDate);
    final notificationDateString = task.notificationDate == null ? null : dateTimeFormatter.format(task.notificationDate);
    return DateState(finalDate: finalDateString, notificationDate: notificationDateString);
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
      _dateStateStreamController.add(_getDateState());
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
      _dateStateStreamController.add(_getDateState());
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

class _TaskDetailSliverAppBar extends StatelessWidget {

  final double height;
  final String title;
  final PopupMenuItemSelected<_TaskDetailPopupMenuItem> onSelected;

  _TaskDetailSliverAppBar({this.height, this.title, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: TaskInfo.of(context).theme.primaryColor,
      pinned: true,
      expandedHeight: height,
      flexibleSpace: FlexibleSpaceBar(
          title: Text(title)
      ),
      actions: <Widget>[
        PopupMenuButton<_TaskDetailPopupMenuItem>(
        onSelected: onSelected,
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<_TaskDetailPopupMenuItem>(
                value: _TaskDetailPopupMenuItem.delete,
                child: Text('Удалить'),
              ),
              PopupMenuItem<_TaskDetailPopupMenuItem>(
                value: _TaskDetailPopupMenuItem.update,
                child: Text('Редактировать'),
              )
            ];
          },
        )
      ],
    );
  }
}

  
class _DateNotificationCard extends StatelessWidget {
  
  final VoidCallback onPickDate;
  final String finalDate;
  final String notificationDate;
  final VoidCallback onNotification;
  
  _DateNotificationCard({this.onPickDate, this.finalDate, this.onNotification, this.notificationDate});
  
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
            title: notificationDate == null ? Text('Напомнить') : Text(notificationDate)
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
            title: finalDate == null ? Text('Добавить дату выполнения')
                  : Text(finalDate),
          )
        ],
      ),
    );
  }
}
