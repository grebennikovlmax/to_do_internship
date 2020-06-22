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
import 'package:todointernship/model/fab_state.dart';

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

    _dateNotifier = ValueNotifier(widget.task.finalDate);
    _titleNameNotifier = ValueNotifier(widget.task.name);


    _scrollController.addListener(() {
      final state = FabState(_scrollController.offset, widget.task.isCompleted);
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
                  PopupMenuButton<TaskDetailPopupMenuItem>(
                    onSelected: _popupMenuButtonPressed,
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
                            title: ValueListenableBuilder<DateTime>(
                              valueListenable: _dateNotifier,
                              builder: (context, value, _) {
                                return Text(value == null ? "Добавить дату выполнения" : dateFormatter.format(value));
                              }
                            ),
                          ),
                        ],
                      ),
                    )
                  ])
              ),
            ]),
        StreamBuilder<FabState>(
          initialData: FabState(0, widget.task.isCompleted),
          stream: _fabStateStream.stream,
          builder: (context, snapshot) {
            return CustomFloatingButton(snapshot.data.isCompleted, snapshot.data.offset, appBarHeight, _fabPressed );
          }
        )]
      );
  }

  void _fabPressed() {
    widget.taskEvent.add(OnCompletedTask(widget.task));
    final state = FabState(_scrollController.offset, !widget.task.isCompleted);
    _fabStateStream.add(state);
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
      _titleNameNotifier.value = name;
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
      _dateNotifier.value = date;
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

