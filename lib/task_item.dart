import 'package:flutter/material.dart';
import 'package:todointernship/task.dart';

class TaskItem extends StatefulWidget {


  final Task task;
  final int index;
  final void Function(int) onRemoveTask;

  TaskItem(this.task, this.onRemoveTask, this.index);

  @override
  State<StatefulWidget> createState() {
    return _TaskItemState();
  }
}

class _TaskItemState extends State<TaskItem> {

  _todoTaped(bool val) {
    setState(() {
      widget.task.isCompleted = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8)
        ),
      child: ListTile(
        title: Text(widget.task.name),
        trailing: GestureDetector(
          child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
          onTap: () => widget.onRemoveTask(widget.index),
        ),
        leading: Checkbox(
            activeColor: Theme.of(context).primaryColor,
            value: widget.task.isCompleted,
            onChanged: (val) => _todoTaped(val)
        ),
      )
    );
  }

}