import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todointernship/pages/category_detail.dart';
import 'package:todointernship/model/category_theme.dart';


class ThemePicker extends StatefulWidget {

  final Sink themeSink;

  ThemePicker(this.themeSink);

  @override
  State<StatefulWidget> createState() {
    return _ThemePickerState();
  }

}
class _ThemePickerState extends State<ThemePicker> {

  List<ThemeData> themes = [
    ThemeData(
      primaryColor: Color(0xfff44336),
      backgroundColor: Color(0xff36e7f4),
    ),
    ThemeData(
      primaryColor: Color(0xffFF5722),
      backgroundColor: Color(0xffffc422),
    ),
    ThemeData(
      primaryColor: Color(0xffffc107),
      backgroundColor: Color(0xff0745ff),
    ),
    ThemeData(
      primaryColor: Color(0xff4CAF50),
      backgroundColor: Color(0xffaf4cac),
    ),
    ThemeData(
      primaryColor: Color(0xff2C98F0),
      backgroundColor: Color(0xff2cf0e6),
    ),
    ThemeData(
      primaryColor: Color(0xff6202EE),
      backgroundColor: Color(0xff916eff),
    )
  ];
  ThemeData pickedTheme;

  StreamController<ThemeData> _themeStreamController;

  final double height = 24;

  @override
  void initState() {
    super.initState();
    _themeStreamController = StreamController();
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
              child: Text("Выбор темы",
                style: TextStyle(
                  fontSize: 18,
                ),
              )
          ) ,
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StreamBuilder<ThemeData>(
                  stream: _themeStreamController.stream,
                  initialData: Theme.of(context),
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
    widget.themeSink.add(theme);
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
            width: radius / 3,
            height: radius / 3,
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