import 'package:flutter/material.dart';

import 'task.dart';

class NewTask extends StatefulWidget {


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
        title: Text("Новое задание"),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      onSaved: (value) {
                        Navigator.of(context).pop(Task(value));
                      },
                      validator: (value) {
                        if(value.isEmpty) return "Задание не может быть пустым";
                        return value.length > 20 ? "Много символов" : null;
                      },
                    )
                ),
                RaisedButton(
                  child: Text("Создать"),
                  onPressed: () =>  _formKey.currentState.validate() ? _formKey.currentState.save() : null,
                )
              ],
            ),
          )
        ]
    );
  }
}