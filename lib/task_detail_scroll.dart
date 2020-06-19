import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/step_item.dart';
import 'package:todointernship/new_task.dart';
import 'package:todointernship/time_picker_dialog.dart';

class TaskDetailScrollView extends StatefulWidget {

  final Task task;
  TaskDetailScrollView(this.task);

  @override
  State<StatefulWidget> createState() {
    return _TaskDetailScrollViewState();
  }

}

enum TaskDetailPopupMenuItem {update, delete}

class _TaskDetailScrollViewState extends State<TaskDetailScrollView> {

  double appBarHeight = 128;
  String date = "";

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[CustomScrollView(
        controller: _scrollController,
          slivers: <Widget>[
//          _setupFab(),
            SliverAppBar(
              pinned: true,
              expandedHeight: appBarHeight,
              flexibleSpace: FlexibleSpaceBar(title: Text(widget.task.name)),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: _createSteps(),
                      )
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
                        Divider(
                          thickness: 2,
                        ),
                        ListTile(
                          leading: Icon(Icons.insert_invitation),
                          onTap: _pickDate,
                          title: Text(date.isEmpty ? "Добавить дату выполнения" : date ),
                        )
                      ],
                    ),
                  )
                ])
            ),
          ]),
      _setupFab()
      ]
    );
  }

  List<Widget> _createSteps() {
    List<Widget> widgets = [];
    String formatDate = DateFormat("dd.MM.yyyy").format(widget.task.date);
    widgets.add(Padding(
      padding: const EdgeInsets.all(14.0),
      child: Text("Создано: $formatDate",
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.6)
        ),
      ),
    ));
    for(var step in widget.task.steps) {
      widgets.add(
          StepItem(
            onDelete: _onDelete,
            step: step,
          ));
    }
    widgets.add(
        ListTile(
          leading: Icon(Icons.add,
            color: Color(0xff1A9FFF)
          ),
          title: Text("Добавить шаг",
            style: TextStyle(
              color: Color(0xff1A9FFF)
            ),
          ),
          onTap: () {
            setState(() {
              widget.task.steps.add(TaskStep(""));
            });
          },
        )
    );

    widgets.add(
        Divider(
          thickness: 2,
          indent: 20,
          endIndent: 20,
        )
    );

    widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Text("Заметки по задаче..."),
        )
    );
    return widgets;
  }

  Future<void> _updateTaskName() async {
    var name = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return NewTask("Редактировть",widget.task.name);
        }
    );
    if(name != null) {
      setState(() {
        widget.task.name = name;
      });
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
      if (platform == TargetPlatform.iOS) {
        date = await showCupertinoModalPopup<DateTime>(
            context: context,
            builder: (context) {
              return CupertinoDatePicker(
                initialDateTime: DateTime.now(),
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
      String formatDate = DateFormat("dd.MM.yyyy").format(date);
      setState(() {
        this.date = formatDate;
      });
    }
  }

  

  _onDelete(TaskStep step) {
    setState(() {
      widget.task.steps.remove(step);
    });
  }

  Widget _setupFab() {
    final double defaultTop = appBarHeight - 4;
    final double scaleStart = 96;
    final double scaleEnd = scaleStart / 2;

    double top = defaultTop;
    double scale = 1;

    if(_scrollController.hasClients) {
      double offset = _scrollController.offset;
      top -= offset;
      if(offset < defaultTop - scaleStart) {
        scale = 1;
      } else if(offset < defaultTop - scaleEnd) {
        scale = (defaultTop - scaleEnd - offset) / scaleEnd;
      } else {
        scale = 0;
      }
    }
    return Positioned(
      top: top,
      left: 16,
      child: Transform(
        transform: Matrix4.identity()
          ..scale(scale),
        alignment: Alignment.center,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              widget.task.isCompleted = !widget.task.isCompleted;
            });
          },
          child: Icon(widget.task.isCompleted ? Icons.clear : Icons.check),
        ),
      ),
    );
  }

  _popupMenuButtonPressed(TaskDetailPopupMenuItem item) {
    switch(item) {
      case TaskDetailPopupMenuItem.delete:
        Navigator.of(context).pop(widget.task);
        break;
      case TaskDetailPopupMenuItem.update:
        _updateTaskName();
        break;
    }
  }

}