import 'package:flutter/material.dart';

class TimePickerDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(10),
      children: <Widget>[
        DateMenu(
          title: "Сегодня",
          onTap: () => _onPickedDate(context, DateTime.now()),
        ),
        Padding(padding: EdgeInsets.all(5)),
        DateMenu(
          title: "Завтра",
          onTap: () => _onPickedDate(context, DateTime.now().add(Duration(days: 1))),
        ),
        Padding(padding: EdgeInsets.all(5)),
        DateMenu(
          title: "На следующей неделе",
          onTap: () => _onPickedDate(context, DateTime.now().add(Duration(days: 7))),
        ),
        Padding(padding: EdgeInsets.all(5)),
        DateMenu(
          title: "Выбрать дату и время",
          onTap: () => _onPickedDate(context, null)
        )
      ],
    );
  }

  void _onPickedDate(BuildContext context, DateTime date) {
    Navigator.of(context).pop(date);
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
       style: TextStyle(
         fontSize: 18,
         color: Color.fromRGBO(0, 0, 0, 0.6)
       ),
     ),
   );
  }
}