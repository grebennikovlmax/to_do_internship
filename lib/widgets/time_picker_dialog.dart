import 'package:flutter/material.dart';
enum _TimeMenu {today, tomorrow, nextWeek, choose}

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
          onTap: () => _onPickedDate(context, _TimeMenu.today),
        ),
        _DialogDivider(),
        DateMenu(
          title: withTime ? 'Завтра (9:00)' : 'Завтра',
          onTap: () => _onPickedDate(context, _TimeMenu.tomorrow),
        ),
        _DialogDivider(),
        DateMenu(
          title: withTime ? 'На следующей неделе (9:00)' : 'На следующей неделе',
          onTap: () => _onPickedDate(context, _TimeMenu.nextWeek),
        ),
        _DialogDivider(),
        DateMenu(
          title: withTime ? 'Выбрать дату и время' : 'Выбрать дату' ,
          onTap: () => _onPickedDate(context, _TimeMenu.choose)
        )
      ],
    );
  }

  void _onPickedDate(BuildContext context, _TimeMenu option) {
    final dateData = DateTimeData(withTime);
    switch (option) {
      case _TimeMenu.today:
        Navigator.of(context).pop(dateData.today());
        break;
      case _TimeMenu.tomorrow:
        Navigator.of(context).pop(dateData.tomorrow());
        break;
      case _TimeMenu.nextWeek:
        Navigator.of(context).pop(dateData.nextWeek());
        break;
      case _TimeMenu.choose:
        _choseDate(context);
        break;
    }
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

class DateTimeData {

  final bool withTime;

  DateTimeData(this.withTime);

  DateTime today() {
    final currentDate = DateTime.now();
    final date = DateTime(currentDate.year,currentDate.month,currentDate.day);
    return withTime ? date.add(Duration(hours: 18)) : date;
  }

  DateTime tomorrow() {
    final currentDate = DateTime.now();
    final date = DateTime(currentDate.year,currentDate.month,currentDate.day + 1);
    return withTime ? date.add(Duration(hours: 9)) : date;
  }

  DateTime nextWeek() {
    final currentDate = DateTime.now();
    final date = DateTime(currentDate.year,currentDate.month,currentDate.day + 7);
    return withTime ? date.add(Duration(hours: 9)) : date;
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