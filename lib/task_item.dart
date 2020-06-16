import 'package:flutter/material.dart';
import 'model/task.dart';
import 'pages/task_detail.dart';

class TaskItem extends StatefulWidget {


  final Task task;
  final int index;
  final void Function(Task) onRemoveTask;

  TaskItem(this.task, this.onRemoveTask, this.index);

  @override
  State<StatefulWidget> createState() {
    return _TaskItemState();
  }
}

class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin{

  _todoTaped(bool val) {
    setState(() {
      widget.task.isCompleted = val;
    });
  }

  String get countSteps {
    int steps = widget.task.stepsCount;
    if(steps == 0) return "";
    int completedSteps = widget.task.steps.where((step) => step.isCompleted == true).length;
    return "$completedSteps из $steps";
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.delete),
          ),
        ),
      ),
      onDismissed: (dir) => widget.onRemoveTask(widget.task),
      key: UniqueKey(),
      child: Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8)
            ),
          child: ListTile(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaskDetail(widget.task))).then((value) {
                      if(value != null) widget.onRemoveTask(widget.task);
                      setState(() {});
                }),
            title: Text(widget.task.name),
            subtitle: Text(countSteps),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
              onTap: () => widget.onRemoveTask(widget.task),
            ),
            leading: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                value: widget.task.isCompleted,
                onChanged: (val) => _todoTaped(val)
            ),
          )
        ),
    );
  }

}