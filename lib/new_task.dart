import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:async';

import 'package:todointernship/time_picker_dialog.dart';
import 'package:todointernship/model/task.dart';


class NewTask extends StatefulWidget {

  final Task task;
  final DateFormat dateFormatter = DateFormat("dd.MM.yyyy");


  NewTask([this.task]);

  @override
  State<StatefulWidget> createState() {
    return _NewTaskState();
  }

}

class _NewTaskState extends State<NewTask> {

  final _formKey = GlobalKey<FormState>();
  DateTime date;
  String taskName;
  
  StreamController<DateTime> _dateStreamController;
  
  
  @override
  void initState() {
    super.initState();
    _dateStreamController = StreamController();
  }
  
  @override
  void dispose() {
    _dateStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  SimpleDialog (
        contentPadding: EdgeInsets.zero,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.fromLTRB(18, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.task == null ? "Создать задачу" : "Изменить задачу",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  TextFormField(
                    initialValue: widget.task?.name ?? "",
                    decoration: InputDecoration(
                      hintText: "Введите название задачи",
                      hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey),
                      border: InputBorder.none
                    ),
                    onSaved: (val) => taskName = val,
                    validator: (value) {
                      if(value.isEmpty) return "Задание не может быть пустым";
                      return value.length > 20 ? "Много символов" : null;
                    },
                  ),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomDialogTile(
                          title: "Напомнить",
                          icon: Icons.notifications_none,
                          onTap: () {},
                        ),
                        Divider(color: Colors.white),
                        StreamBuilder<DateTime>(
                          initialData: widget.task?.finalDate,
                          stream: _dateStreamController.stream,
                          builder: (context, snapshot) {
                            return FormField<DateTime>(
                              validator: (value) {
                                return value == null ? "Дата не может быть пустой" : null;
                              },
                              onSaved: (val) => date = val,
                              builder: (state) {
                              return CustomDialogTile(
                                title: snapshot.data == null 
                                    ? "Дата выполнения" 
                                    : widget.dateFormatter.format(snapshot.data),
                                icon: Icons.insert_invitation,
                                onTap: () => _onPickDate(state),
                              );
                              },
                            );
                          }
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Отмена",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                        padding: EdgeInsets.zero,
                        child: Text(widget.task == null ? "Создать" : "Изменить",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        onPressed: _onSave
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ]
    );
  }

  Future<void> _onPickDate(FormFieldState state) async {
    DateTime date = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return TimePickerDialog();
        }
        );
    date ??= await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100)
    );
    if(date != null)
    _dateStreamController.add(date);
    state.didChange(date);
  }

  _onSave() {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      final task = Task(taskName, date);
      Navigator.of(context).pop(task);
    }
  }
}

class CustomDialogTile extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  CustomDialogTile({this.title, this.icon, this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Color(0xffB5C9FD),
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(icon),
            VerticalDivider(width: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  
}