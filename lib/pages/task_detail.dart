import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/new_task.dart';

class TaskDetail extends StatefulWidget {

  final Task task;
  TaskDetail(this.task);

  @override
  State<StatefulWidget> createState() {
    return _TaskDetailState();
  }

}

enum TaskDetailPopupMenuItem {update, delete}

class _TaskDetailState extends State<TaskDetail> {

  bool isButton = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
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
      body: Center(
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _createSteps(),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(widget.task.isCompleted ? Icons.clear : Icons.check),
        onPressed: () {
          setState(() {
            widget.task.isCompleted = !widget.task.isCompleted;
          });
        },
      ),
    );
  }

  List<Widget> _createSteps() {
    List<Widget> widgets = [];
    for(var step in widget.task.steps) {
      widgets.add(
        ListTile(
          title: Text(step.description),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                widget.task.steps.remove(step);
              });
            },
          ),
          leading: Checkbox(
            value: step.isCompleted,
            onChanged: (val) {
              setState(() {
                step.isCompleted = val;
              });
            },
          ),
        )
      );
    }
    if(isButton) {
      widgets.add(FlatButton(
        child: Text("Добавить шаг"),
        onPressed: () {
          setState(() {
            isButton = false;
          });
        },
        )
      );
    } else {
      widgets.add(TextField(
        autofocus: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          hintText: "Новый шаг",
        ),
        onSubmitted: (val) {
          setState(() {
            isButton = true;
            if(val.isEmpty) return;
            widget.task.steps.add(TaskStep(val));
          });
        },
      ));
    }

    return widgets;
  }

}