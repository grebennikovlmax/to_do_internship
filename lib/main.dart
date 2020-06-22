import 'package:flutter/material.dart';

import 'package:todointernship/pages/task_detail.dart';
import 'package:todointernship/pages/category_detail.dart';
import 'package:todointernship/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/category_detail" : (context) => CategoryDetail(ModalRoute.of(context).settings.arguments),
        "/task_detail" : (context) => TaskDetail(ModalRoute.of(context).settings.arguments)
      },
      theme: ThemeData(
        primaryColor: Color(0xff6202EE),
        accentColor: Color(0xff01A39D),
        backgroundColor: Colors.indigo[100]
      ),
      home: HomePage()
    );
  }

}
