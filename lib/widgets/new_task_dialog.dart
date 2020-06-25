import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:async';

import 'package:todointernship/widgets/time_picker_dialog.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/date_state.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';


class NewTaskDialog extends StatefulWidget {

  final Task task;
  final DateFormat dateFormatter = DateFormat("dd.MM.yyyy");


  NewTaskDialog({this.task});

  @override
  State<StatefulWidget> createState() {
    return _NewTaskDialogState();
  }

}

class _NewTaskDialogState extends State<NewTaskDialog> {

  final _formKey = GlobalKey<FormState>();
  DateTime finalDate;
  DateTime notificationDate;
  String taskName;
  
  StreamController<DateState> _dateStateStreamController;
  
  
  @override
  void initState() {
    super.initState();
    finalDate = widget.task?.finalDate;
    notificationDate = widget.task?.notificationDate;
    _dateStateStreamController = StreamController();
  }
  
  @override
  void dispose() {
    _dateStateStreamController.close();
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
                  StreamBuilder<DateState>(
                    stream: _dateStateStreamController.stream,
                    initialData: _getDateState(),
                    builder: (context, snapshot) {
                      return Column(
                        children: <Widget>[
                          _DateFormField(
                            title: snapshot.data.notificationDate == null ? 'Напомнить' : snapshot.data.notificationDate,
                            onTap: _onPickNotification,
                            icon: Icons.notifications_none,
                            onSaved: (val) => notificationDate = val ,
                          ),
                          Divider(color: Colors.transparent),
                          _DateFormField(
                            title: snapshot.data.finalDate == null ? 'Дата выполнения' : snapshot.data.finalDate,
                            onTap: _onPickDate,
                            icon:  Icons.insert_invitation,
                            onSaved: (val) => finalDate = val,
                          )
                        ],
                      );
                    },
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
    final date = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return TimePickerDialog(withTime: false);
        }
        );
    if(date != null)  {
      finalDate = date;
      _dateStateStreamController.add(_getDateState());
      state.didChange(date);
    }
  }

  Future<void> _onPickNotification(FormFieldState state) async {
    final dateTime = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return TimePickerDialog(withTime: true);
      }
    );
    if(dateTime != null) {
      notificationDate = dateTime;
      _dateStateStreamController.add(_getDateState());
      state.didChange(dateTime);
    }
  }

  DateState _getDateState() {
    DateFormat dateFormatter = DateFormat("dd.MM.yyyy");
    DateFormat dateTimeFormatter = DateFormat("dd.MM.yyyy H:mm");
    final task = widget.task;
    final finalDateString = finalDate == null ? null : dateFormatter.format(finalDate);
    final notificationDateString = notificationDate == null ? null : dateTimeFormatter.format(notificationDate);
    return DateState(finalDate: finalDateString, notificationDate: notificationDateString);
  }

  _onSave() async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      final task = Task(
        name: taskName,
        finalDate: finalDate,
        notificationDate: notificationDate,
      );
      final res = await TaskDatabaseRepository.shared.saveTask(task);
      task.id = res;
      if(notificationDate != null) {
        final platformManager = PlatformNotificationChannel();
        await platformManager.setNotification(task);
      }
      Navigator.of(context).pop(task);
    }
  }
}

class _DateFormField extends StatelessWidget {
  
  final String title;
  final IconData icon;
  final void Function(FormFieldState) onTap;
  final FormFieldSetter<DateTime> onSaved;
  
  _DateFormField({this.title, this.onTap, this.icon, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      onSaved: onSaved,
      builder: (FormFieldState state) {
        return GestureDetector(
          onTap: () => onTap(state),
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
                      style: Theme.of(context).textTheme.bodyText2
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

}