import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/custom_checkbox.dart';

class StepItem extends StatefulWidget {

  final VoidCallback onDelete;
  final TaskStep step;

  StepItem({this.onDelete,this.step});

  @override
  State<StatefulWidget> createState() {
    return _StepItemState();
  }
}

class _StepItemState extends State<StepItem> {

  StreamController<TaskStep> _streamController;

  bool isEditing;

  @override
  initState() {
    super.initState();
    isEditing = widget.step.description.isEmpty;
    _streamController = StreamController();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskStep>(
      stream: _streamController.stream,
      initialData: widget.step,
      builder: (context, snapshot) {
        return ListTile(
          onTap: _endEditing,
          leading: CustomCheckBox(
            value: snapshot.data.isCompleted,
            onChange: _onChange,
            color: Scaffold.of(context).widget.backgroundColor,
          ),
          title: isEditing ? TextFormField(
              textInputAction: TextInputAction.done,
              maxLines: null,
              autofocus: true,
              initialValue: snapshot.data.description,
              onFieldSubmitted: (val) {
                widget.step.description = val;
                _endEditing();
              })
              : Text(widget.step.description),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: widget.onDelete,
          ),
        );
      }
    );
  }

  void _onChange() {
    widget.step.isCompleted = !widget.step.isCompleted;
    _streamController.add(widget.step);
  }

  void _endEditing() {
    isEditing = !isEditing;
    _streamController.add(widget.step);
  }

}

