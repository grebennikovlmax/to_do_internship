import 'package:flutter/material.dart';

import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_picker_bloc.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_state.dart';
import 'package:todointernship/widgets/time_picker_dialog.dart';

class DateNotificationCard extends StatefulWidget {

  final Sink<TaskEvent> taskEditingSink;
  final DateTime finalDate;
  final DateTime notificationDate;

  DateNotificationCard({this.taskEditingSink, this.notificationDate, this.finalDate});

  @override
  _DateNotificationCardState createState() => _DateNotificationCardState();
}

class _DateNotificationCardState extends State<DateNotificationCard> {

  DatePickerBloc _datePickerBloc;

  @override
  void initState() {
    super.initState();
    _datePickerBloc = DatePickerBloc(
        finalDate: widget.finalDate,
        notificationDate: widget.notificationDate
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateState>(
      stream: _datePickerBloc.dateStateStream,
      builder: (context, snapshot) {
        if(!snapshot.hasData) return Container();
        var finalColor = _setColor(snapshot.data.finalDayIsExpired);
        var notificationColor = _setColor(snapshot.data.notificationDayIsExpired);
        return Card(
          margin: EdgeInsets.fromLTRB(16, 10, 16, 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  onTap: _onPickNotification,
                  leading: Icon(Icons.notifications_none,
                    color: notificationColor,
                  ),
                  title: snapshot.data.notificationDate == null
                      ? Text('Напомнить')
                      : Text(snapshot.data.notificationDate,
                          style: TextStyle(
                            color: notificationColor
                      )
                  )
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: Divider(
                  thickness: 2,
                ),
              ),
              ListTile(
                leading: Icon(Icons.insert_invitation,
                  color: finalColor
                ),
                onTap: _onPickDate,
                title: snapshot.data.finalDate == null
                    ? Text('Добавить дату выполнения')
                    : Text(snapshot.data.finalDate,
                        style: TextStyle(
                            color: finalColor
                        )
                ),
              )
            ],
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    _datePickerBloc.dispose();
    super.dispose();
  }

  Future<void> _onPickDate() async{
    var date = await showDialog(
        context: context,
        builder: (context) {
          return TimePickerDialog(withTime: false);
        }
    );
    if(date != null) {
      widget.taskEditingSink.add(UpdateTaskFinalDateEvent(date));
      _datePickerBloc.dateEventSink.add(DateEvent(finalDate: date));
    }
  }

  Future<void> _onPickNotification() async {
    var date = await showDialog(
        context: context,
        builder: (context) {
          return TimePickerDialog(withTime: true);
        }
    );
    if(date != null) {
      widget.taskEditingSink.add(UpdateTaskNotificationDateEvent(date));
      _datePickerBloc.dateEventSink.add(DateEvent(notificationDate: date));
    }
  }


  Color _setColor(bool isExpired) {
    if(isExpired == null) {
      return Colors.grey;
    }
    return isExpired ? Colors.red : Colors.blue;
  }
}
