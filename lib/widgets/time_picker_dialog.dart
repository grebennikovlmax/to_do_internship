import 'package:flutter/material.dart';
import 'package:todointernship/extension/date_time_extension.dart';

class TimePickerDialog extends StatelessWidget {

  final bool withTime;

  TimePickerDialog({this.withTime});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(10),
      children: <Widget>[
        DateMenu(
          title: withTime ? 'Сегодня (18:00)': 'Сегодня',
          onTap: () => Navigator.of(context).pop(PickDate.today()),
        ),
        _DialogDivider(),
        DateMenu(
          title: withTime ? 'Завтра (9:00)' : 'Завтра',
          onTap: () => Navigator.of(context).pop(PickDate.tomorrow()),
        ),
        _DialogDivider(),
        DateMenu(
          title: withTime ? 'На следующей неделе (9:00)' : 'На следующей неделе',
          onTap: () => Navigator.of(context).pop(PickDate.nextWeek()),
        ),
        _DialogDivider(),
        DateMenu(
          title: withTime ? 'Выбрать дату и время' : 'Выбрать дату' ,
          onTap: () => _choseDate(context)
        )
      ],
    );
  }

  void _choseDate(BuildContext context) async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 10000))
    );
    if(withTime && date != null) {
      final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 0, minute: 0)
      );
      if(time != null) {
        date = date.add(Duration(hours: time.hour, minutes: time.minute));
      }
    }
    Navigator.of(context).pop(date);
  }

}

class _DialogDivider extends StatelessWidget {

  final double height = 10;
  final color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      color: color,
    );
  }
}

class DateMenu extends StatelessWidget {

  final VoidCallback onTap;
  final String title;

  DateMenu({this.onTap, this.title});

  @override
  Widget build(BuildContext context) {
   return GestureDetector(
     onTap: onTap,
     child: Text(title,
       style: Theme.of(context).textTheme.bodyText2.copyWith(
         fontSize: 18,
         color: Colors.grey
       )
     ),
   );
  }
}
