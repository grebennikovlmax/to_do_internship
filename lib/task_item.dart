import 'package:flutter/material.dart';

import 'package:todointernship/model/task_event.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/custom_checkbox.dart';


class TaskItem extends StatelessWidget {

  final Task task;
  final Sink sink;

  TaskItem({this.task, this.sink});

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
      onDismissed: (dir) => {
        sink.add(OnRemoveTask(task))
      },
      key: UniqueKey(),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
          ),
          child: ListTile(
            onTap: () => Navigator.pushNamed(context, "/task_detail",arguments: task),
            title: Text(task.name),
            subtitle: countSteps.isEmpty ? null : Text(countSteps),
            leading: CustomCheckBox(
              value: task.isCompleted,
              onChange: () {
                sink.add(OnCompletedTask(task));
              },
            ),
          )
      ),
    );
  }

  String get countSteps {
    int steps = task.stepsCount;
    if(steps == 0) return "";
    int completedSteps = task.steps.where((step) => step.isCompleted == true).length;
    return "$completedSteps из $steps";
  }



}

//class TaskItem extends StatefulWidget {
//
//
//  final Task task;
//
//  TaskItem({this.task});
//
//  @override
//  State<StatefulWidget> createState() {
//    return _TaskItemState();
//  }
//}
//
//class _TaskItemState extends State<TaskItem> {
//
//  _onChanged() {
//    setState(() {
//      widget.task.isCompleted = !widget.task.isCompleted;
//    });
//  }
//
//  String get countSteps {
//    int steps = widget.task.stepsCount;
//    if(steps == 0) return "";
//    int completedSteps = widget.task.steps.where((step) => step.isCompleted == true).length;
//    return "$completedSteps из $steps";
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Dismissible(
//      direction: DismissDirection.endToStart,
//      background: Container(
//        decoration: BoxDecoration(
//          color: Colors.red,
//          borderRadius: BorderRadius.circular(10)
//        ),
//        child: Align(
//          alignment: Alignment.centerRight,
//          child: Padding(
//            padding: EdgeInsets.only(right: 10),
//            child: Icon(Icons.delete,color: Colors.white,),
//          ),
//        ),
//      ),
//      onDismissed: (dir) {},
//      key: UniqueKey(),
//      child: Container(
//            decoration: BoxDecoration(
//            color: Colors.white,
//            borderRadius: BorderRadius.circular(8)
//            ),
//          child: ListTile(
//            onTap: () => Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => TaskDetail(widget.task))).then((value) {
//                      setState(() {});
//                }),
//            title: Text(widget.task.name),
//            subtitle: countSteps.isEmpty ? null : Text(countSteps),
////            trailing: IconButton(
////              onPressed: () => widget.onRemoveTask(widget.task),
////              icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
////            ),
//            leading: CustomCheckBox(
//              value: widget.task.isCompleted,
//              onChange: _onChanged,
//            ),
//          )
//        ),
//    );
//  }
//
//}