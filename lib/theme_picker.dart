import 'dart:async';
import 'dart:ffi';

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

  StreamController<ThemeData> _themeStreamController;

  final double height = 24;

  @override
  void initState() {
    super.initState();
    _themeStreamController = StreamController();
    pickedTheme = widget.theme;
    themes.add(widget.theme);
  }

  @override
  void dispose() {
    _themeStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text("Выбор темы")) ,
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StreamBuilder<ThemeData>(
                  stream: _themeStreamController.stream,
                  initialData: pickedTheme,
                  builder: (context, snapshot) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: themes.length,
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                       return Padding(
                         padding: EdgeInsets.only(right: 10),
                         child: CustomThemPickerButton(
                           radius: height,
                           color: themes[index].primaryColor,
                           onTap: () => _changeTheme(themes[index]),
                           value: themes[index] == snapshot.data,
                         ),
                       );
                      });
                  }
                )
              ]
            ),
          )
        ],
          ),
    );
  }

  _changeTheme(ThemeData theme) {
    _themeStreamController.add(theme);
  }
}

class CustomThemPickerButton extends StatelessWidget {
  
  final Color color;
  final VoidCallback onTap;
  final bool value;
  final double radius;
  
  CustomThemPickerButton({this.radius, this.color, this.onTap, this.value});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color
        ),
        child: value ? Center(
          child: Container(
            width: radius / 2,
            height: radius / 2,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
            ),
          ),
        ) : null
      ),
    );
  }
  
  
}