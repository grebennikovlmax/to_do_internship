import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/authorization_page/authorization_page.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/global_scope_container.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page.dart';
import 'package:todointernship/pages/task_list_page/task_list_page.dart';
import 'package:todointernship/pages/category_list_page/category_list_page.dart';
import 'package:todointernship/theme_bloc.dart';
import 'file:///C:/Users/Grebennikov.MS/AndroidStudioProjects/todo_internship/lib/widgets/phone_camera/phone_camera.dart';

void main() {
  GlobalScopeContaier()
      ..init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (context) => ThemeBloc(Injector.appInstance.getDependency<SharedPrefManager>()),
      child: MaterialApp(
          initialRoute: '/',
          routes: {
            '/app': (context) => CategoryListPage(),
            '/category_detail' : (context) => TaskListPage(ModalRoute.of(context).settings.arguments),
            '/task_detail' : (context) => TaskDetailPage(ModalRoute.of(context).settings.arguments),
            '/photo_picker': (context) => ImagePickerPage(ModalRoute.of(context).settings.arguments),
            '/camera' : (context) => PhoneCamera(ModalRoute.of(context).settings.arguments)
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
          home: AuthorizationPage(),
      ),
    );
  }

}
