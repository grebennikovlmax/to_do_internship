import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_picker_bloc.dart';
import 'package:todointernship/widgets/time_picker_dialog.dart';

class TaskCreationDialog extends StatefulWidget {

  final bool edit;
  final String name;
  final Sink<TaskEvent> creationEventSink;

  TaskCreationDialog({this.name, @required this.edit, this.creationEventSink});

  @override
  _TaskCreationDialogState createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {

  final _formKey = GlobalKey<FormState>();
  DatePickerBloc _block;

  String name;
  DateTime finalDate;
  DateTime notificationDate;

  @override
  void initState() {
    super.initState();
    _block = DatePickerBloc();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 12, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.edit ? 'Изменить задачу' : 'Создать задачу',
                  style: Theme.of(context).textTheme.headline5,
                ),
                TextFormField(
                  initialValue: widget.edit ? widget.name : '',
                  decoration: InputDecoration(
                      hintText: "Введите название задачи",
                      hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey),
                      border: InputBorder.none
                  ),
                  onSaved: (val) => name = val,
                  validator: (value) {
                    if(value.isEmpty) return "Задание не может быть пустым";
                    return value.length > 20 ? "Много символов" : null;
                  },
                ),
                widget.edit
                    ? Container()
                    : BlocBuilder(
                      bloc: _block,
                      builder: (context, snapshot) {
                        return FractionallySizedBox(
                          widthFactor: 0.7,
                          child: Column(
                            children: <Widget>[
                              _DateFormField(
                                title: snapshot.notificationDate,
                                onTap: _onPickNotification ,
                                icon: Icons.notifications_none,
                                onSaved: (val) =>  notificationDate = val,
                              ),
                              Divider(color: Colors.transparent),
                              _DateFormField(
                                title: snapshot.finalDate,
                                onTap: _onPickDate,
                                icon:  Icons.insert_invitation,
                                onSaved: (val) => finalDate = val,
                              )
                            ],
                          ),
                        );
                      },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Отмена',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                        padding: EdgeInsets.zero,
                        child: Text(widget.edit ? 'Изменить' : 'Создать',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        onPressed: _onSaveForm
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _block.close();
    super.dispose();
  }

  Future<void> _onPickDate(FormFieldState state) async {
    var date = await showDialog<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return TimePickerDialog(withTime: false);
        }
    );
    if(date != null) {
      _block.add(DateEvent(finalDate: date));
      state.didChange(date);
    }
  }

  Future<void> _onPickNotification(FormFieldState state) async {
    var dateTime = await showDialog<DateTime>(
        context: context,
        builder: (context) {
          return TimePickerDialog(withTime: true);
        }
    );
    if(dateTime != null) {
      _block.add(DateEvent(notificationDate: dateTime));
      state.didChange(dateTime);
    }
  }

  void _onSaveForm() {
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var event = widget.edit
          ? UpdateTaskNameEvent(name)
          : NewTaskEvent(finalDate,notificationDate,name);
      widget.creationEventSink.add(event);
      Navigator.of(context).pop();
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