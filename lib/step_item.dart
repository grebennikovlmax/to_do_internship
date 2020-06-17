import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/custom_checkbox.dart';

class StepItem extends StatefulWidget {

  final void Function(TaskStep) onDelete;
  final TaskStep step;

  StepItem({this.onDelete,this.step});

  @override
  State<StatefulWidget> createState() {
    return _StepItemState();
  }
}

class _StepItemState extends State<StepItem> {

  bool isEditing;

  initState() {
    super.initState();
    isEditing = widget.step.description.isEmpty;
  }

  _onChange() {
    setState(() {
      widget.step.isCompleted = !widget.step.isCompleted;
    });
  }

  _endEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _endEditing,
      leading: CustomCheckBox(
        value: widget.step.isCompleted,
        onChange: _onChange,
      ),
      title: isEditing ? TextFormField(
          textInputAction: TextInputAction.done,
          maxLines: null,
          autofocus: true,
          initialValue: widget.step.description,
          onEditingComplete: () => print("endEd"),
          onFieldSubmitted: (val) {
            widget.step.description = val;
            _endEditing();
          }
      ) : Text(widget.step.description),
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => widget.onDelete(widget.step),
      ),
    );
  }

}

