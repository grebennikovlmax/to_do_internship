import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todointernship/data/task_data/task_repository.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/widgets/custom_checkbox.dart';

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

  StreamController<TaskStep> _stepStreamController;

  bool isEditing;

  @override
  initState() {
    super.initState();
    isEditing = widget.step.description.isEmpty;
    _stepStreamController = StreamController();
  }

  @override
  void dispose() {
    _stepStreamController.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskStep>(
        stream: _stepStreamController.stream,
        initialData: widget.step,
        builder: (context, snapshot) {
          return ListTile(
            onTap: () => _endEditing(null),
            leading: CustomCheckBox(
              value: snapshot.data.isCompleted,
              onChange: _onChange,
              color: Scaffold
                  .of(context)
                  .widget
                  .backgroundColor,
            ),
            title: isEditing ? TextFormField(
                textInputAction: TextInputAction.done,
                maxLines: null,
                autofocus: true,
                initialValue: snapshot.data.description,
                onFieldSubmitted: _endEditing)
                : Text(widget.step.description),
            trailing: IconButton(
              icon: Icon(Icons.clear),
              onPressed: widget.onDelete,
            ),
          );
        }
    );
  }

  void _onChange() async {
    widget.step.isCompleted = !widget.step.isCompleted;
    await TaskDatabaseRepository.shared.updateStep(widget.step);
    _stepStreamController.add(widget.step);
  }

  void _endEditing(String val) async {
    isEditing = !isEditing;
    if (val != null) {
      widget.step.description = val;
      await TaskDatabaseRepository.shared.updateStep(widget.step);
    }
    _stepStreamController.add(widget.step);
  }


}