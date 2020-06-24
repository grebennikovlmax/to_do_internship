import 'package:flutter/material.dart';

import 'package:todointernship/pages/task_detail_page/task_detail_page.dart';
import 'package:todointernship/pages/task_list_page/task_list_page.dart';
import 'package:todointernship/pages/category_list_page/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: "/",
        routes: {
          "/category_detail" : (context) => TaskListPage(ModalRoute.of(context).settings.arguments),
          "/task_detail" : (context) => TaskDetailPage(ModalRoute.of(context).settings.arguments)
        },
        theme: ThemeData(
          primaryColor: Color(0xff6202EE),
          accentColor: Color(0xff01A39D),
          backgroundColor: Colors.indigo[100],
          textTheme: TextTheme(
            headline5: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w500,
              fontSize: 14
            ),
            bodyText2: TextStyle(
              fontFamily: "Roboto",
              fontSize: 14
            ),
            headline1: TextStyle(
              fontFamily: "Roboto",
              letterSpacing: 0.15,
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900
            )
          )
        ),
        home: HomePage()
    );
  }

}
