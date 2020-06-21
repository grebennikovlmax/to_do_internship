import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:async';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/task_event.dart';
import 'package:todointernship/new_task.dart';
import 'package:todointernship/time_picker_dialog.dart';
import 'package:todointernship/widgets/custom_fab.dart';
import 'package:todointernship/widgets/steps_card.dart';

class TaskDetailScrollView extends StatefulWidget {

  final Task task;
  final Sink taskEvent;
  TaskDetailScrollView(this.task,this.taskEvent);

  @override
  State<StatefulWidget> createState() {
    return _TaskDetailScrollViewState();
  }

}

enum TaskDetailPopupMenuItem {update, delete}

class _TaskDetailScrollViewState extends State<TaskDetailScrollView> {

  double appBarHeight = 128;
  DateFormat dateFormatter = DateFormat("dd.MM.yyyy");

  ScrollController _scrollController;
  StreamController<double> _fabOffsetStream;
  StreamController<List<TaskStep>> _stepListStreamController;
  StreamController<DateTime> _dateStreamController;
  StreamController<String> _titleNameStreamController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabOffsetStream = StreamController();
    _stepListStreamController = StreamController();
    _dateStreamController = StreamController();
    _titleNameStreamController = StreamController();


    _scrollController.addListener(() {
      _fabOffsetStream.add(_scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabOffsetStream.close();
    _stepListStreamController.close();
    _titleNameStreamController.close();
    _dateStreamController.close();
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
                pinned: true,
                expandedHeight: appBarHeight,
                flexibleSpace: FlexibleSpaceBar(
                    title: StreamBuilder<String>(
                      stream: _titleNameStreamController.stream,
                      initialData: widget.task.name,
                      builder: (context, snapshot) {
                        return Text(snapshot.data);
                      }
                    )),
                actions: <Widget>[
                  PopupMenuButton<TaskDetailPopupMenuItem>(
                    onSelected: (val) => _popupMenuButtonPressed(val),
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
                  )
                ],
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                    Card(
                      margin: EdgeInsets.fromLTRB(16, 28, 16, 10),
                      child: StreamBuilder<List<TaskStep>>(
                        initialData: widget.task.steps,
                        stream: _stepListStreamController.stream,
                        builder: (context, snapshot) {
                          widget.task.steps = snapshot.data;
                          return StepsCard(snapshot.data, widget.task.createdDate, _stepListStreamController.sink);
                        }
                      ),
                    ),
                    Card(
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
                            onTap: _pickDate,
                            title: StreamBuilder<DateTime>(
                              stream: _dateStreamController.stream,
                              initialData: widget.task.finalDate,
                              builder: (context, snapshot) {
                                return Text(snapshot.data == null ? "Добавить дату выполнения" : dateFormatter.format(widget.task.finalDate));
                              }
                            ),
                          ),
                        ],
                      ),
                    )
                  ])
              ),
            ]),
        StreamBuilder<double>(
          initialData: 0,
          stream: _fabOffsetStream.stream,
          builder: (context, snapshot) {
            return CustomFloatingButton(widget.task.isCompleted, snapshot.data, appBarHeight, _fabPressed );
          }
        )]
      );
  }

  void _fabPressed() {
    widget.taskEvent.add(OnCompletedTask(widget.task));
    setState(() {

    });
  }

  Future<void> _updateTaskName() async {
    var name = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return NewTask("Редактировть",widget.task.name);
        }
    );
    if(name != null) {
      widget.task.name = name;
      _titleNameStreamController.add(name);
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
      widget.task.finalDate = date;
      _dateStreamController.add(widget.task.finalDate);
    }
  }

  _popupMenuButtonPressed(TaskDetailPopupMenuItem item) {
      switch (item) {
        case TaskDetailPopupMenuItem.delete:
          widget.taskEvent.add(OnRemoveTask(widget.task));
          Navigator.of(context).pop();
          break;
        case TaskDetailPopupMenuItem.update:
          _updateTaskName();
          break;
      }
    }
  }

