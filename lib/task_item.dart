import 'package:flutter/material.dart';
import 'model/task.dart';
import 'pages/task_detail.dart';
import 'custom_checkbox.dart';

class TaskItem extends StatefulWidget {


  final Task task;

  TaskItem(this.task);

  @override
  State<StatefulWidget> createState() {
    return _TaskItemState();
  }
}

class _TaskItemState extends State<TaskItem> {

  _onChanged() {
    setState(() {
      widget.task.isCompleted = !widget.task.isCompleted;
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
            child: Icon(Icons.delete,color: Colors.white,),
          ),
        ),
      ),
      onDismissed: (dir) => {},
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
                      setState(() {});
                }),
            title: Text(widget.task.name),
            subtitle: countSteps.isEmpty ? null : Text(countSteps),
//            trailing: IconButton(
//              onPressed: () => widget.onRemoveTask(widget.task),
//              icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
//            ),
            leading: CustomCheckBox(
              value: widget.task.isCompleted,
              onChange: _onChanged,
            ),
          )
        ),
    );
  }

}