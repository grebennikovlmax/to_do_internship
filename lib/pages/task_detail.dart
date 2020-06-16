import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';

class TaskDetail extends StatefulWidget {

  final Task task;
  TaskDetail(this.task);

  @override
  State<StatefulWidget> createState() {
    return _TaskDetailState();
  }

}

class _TaskDetailState extends State<TaskDetail> {

  bool isButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _createSteps(),
          )
        ),
      )
    );
  }

  List<Widget> _createSteps() {
    List<Widget> widgets = [];
    for(var step in widget.task.steps) {
      widgets.add(
        ListTile(
          title: Text(step.description),
          trailing: IconButton(
            icon: Icon(Icons.delete),
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