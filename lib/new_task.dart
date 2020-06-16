import 'package:flutter/material.dart';

import 'model/task.dart';

class NewTask extends StatefulWidget {

  final String title;
  final String taskValue;

  NewTask(this.title,[this.taskValue = ""]);

  @override
  State<StatefulWidget> createState() {
    return _NewTaskState();
  }

}

class _NewTaskState extends State<NewTask> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return  SimpleDialog (
        title: Text(widget.title),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      initialValue: widget.taskValue,
                      onSaved: (value) {
                        Navigator.of(context).pop(value);
                      },
                      autofocus: true,
                      validator: (value) {
                        if(value.isEmpty) return "Задание не может быть пустым";
                        return value.length > 20 ? "Много символов" : null;
                      },
                    )
                ),
                RaisedButton(
                  child: Text(widget.taskValue.isEmpty ? "Создать" : "Изменить"),
                  onPressed: () =>  _formKey.currentState.validate() ? _formKey.currentState.save() : null,
                )
              ],
            ),
          )
        ]
    );
  }
}