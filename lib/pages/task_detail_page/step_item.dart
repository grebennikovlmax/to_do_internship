import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/widgets/custom_checkbox.dart';

class StepItem extends StatelessWidget {

  final VoidCallback onDelete;
  final TaskStep step;
  final void Function([String]) onTextEditing;
  final VoidCallback onCompleted;

  StepItem({this.onDelete,this.step, this.onTextEditing, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: onTextEditing,
        leading: CustomCheckBox(
          value: step.isCompleted,
          onChange: onCompleted,
          color: Scaffold
              .of(context)
              .widget
              .backgroundColor,
        ),
        title: step.isEditing ? TextFormField(
            textInputAction: TextInputAction.done,
            maxLines: null,
            autofocus: true,
            initialValue: step.description,
            onFieldSubmitted: onTextEditing)
            : Text(step.description),
        trailing: IconButton(
          icon: Icon(Icons.clear),
          onPressed: onDelete,
        ),
      );
  }
}