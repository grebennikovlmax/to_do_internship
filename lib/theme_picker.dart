import 'package:flutter/material.dart';

class ThemePicker extends StatefulWidget {

  final ThemeData theme;
  final void Function(ThemeData) onChangeTheme;

  ThemePicker(this.theme, this.onChangeTheme);

  @override
  State<StatefulWidget> createState() {
    return _ThemePickerState();
  }

}
class _ThemePickerState extends State<ThemePicker> {

  List<Color> colors = [Colors.red, Colors.blue, Colors.amber, Colors.cyan];
  List<ThemeData> themes = [
    ThemeData(
      primaryColor: Colors.purple[500],
      backgroundColor: Colors.purple[200],
    ),
    ThemeData(
      primaryColor: Colors.purple[700],
      backgroundColor: Colors.teal[200],
    ),
    ThemeData(
      primaryColor: Colors.black,
      backgroundColor: Colors.white,
    ),
    ThemeData(
      primaryColor: Colors.blue[700],
      backgroundColor: Colors.greenAccent,
    )
  ];
  ThemeData pickedTheme ;

  @override
  void initState() {
    super.initState();
    pickedTheme = widget.theme;
    themes.add(widget.theme);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text("Выбор темы") ,
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _createRadio()
      )
    ],
    )
    );
  }

  List<Widget> _createRadio() {
    List<Widget> widgets = [];
    for(var theme in themes) {
      widgets.add(
        Radio(
          value: theme,
          activeColor: theme.primaryColor,
          groupValue: pickedTheme,
          onChanged: (val) {
            setState(() {
              pickedTheme = val;
              widget.onChangeTheme(val);
            });
          },
        )
      );
    }
    return widgets;
  }

}