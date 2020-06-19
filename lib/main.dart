import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/new_task.dart';
import 'package:todointernship/empty_task_list.dart';
import 'package:todointernship/pages/category_detail.dart';
import 'package:todointernship/pages/task_detail.dart';
import 'package:todointernship/popup_menu.dart';
import 'package:todointernship/theme_picker.dart';
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

//class MyApp extends StatefulWidget {
//
//  @override
//  State<StatefulWidget> createState() {
//    return _MyAppState();
//  }
//
//}
//
//class _MyAppState extends State<MyApp> {
//
//  ThemeData theme = ThemeData(
//      primaryColor: Color(0xff6202EE),
//      accentColor: Color(0xff01A39D),
//      backgroundColor: Colors.indigo[100]
//  );
//
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Title',
//      theme: theme,
//      home: HomePage(),
////      home: MyHomePage(title: "Title",onChangeTheme: _onChangeTheme,activeTheme: theme),
//    );
//  }
//
//  _onChangeTheme(ThemeData newTheme) {
//    setState(() {
//      theme = newTheme;
//    });
//  }
//}

class MyHomePage extends StatefulWidget {

  final String title;
  final void Function(ThemeData) onChangeTheme;
  final ThemeData activeTheme;

  MyHomePage({Key key, this.title, this.onChangeTheme, this.activeTheme}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _completedIsHidden = false;

  List<Task> filteredTasks = [];

  List<Task> tasks = [
    Task("Дорисовать дизайн"),
    Task("Дописать план")
  ];

  @override
  void initState() {
    Task newTask = Task("Дописать тз на стражировку");
    var step1 = TaskStep("Написать часть про главный экран");
    var step2 = TaskStep("Очень сложный длинный шаг, на который легко наткнуться, сложно выполнить и невозможно забыть");
    newTask.steps.add(step1);
    newTask.steps.add(step2);
    tasks.add(newTask);
    super.initState();
  }

  _removeCompletedTasks() {
    setState(() {
      tasks = tasks.where((task) => task.isCompleted == false).toList();
    });
  }

  _changeTheme(BuildContext context) {
    showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ThemePicker(widget.activeTheme, _onPickNewColor);
        });
  }

  _onPickNewColor(ThemeData theme) {
    widget.onChangeTheme(theme);
  }
  
  _hideCompletedTasks() {
    setState(() {
      filteredTasks = _completedIsHidden ? [] : tasks.where((element) => element.isCompleted == false).toList() ;
      filteredTasks.forEach((element) {print(element.name);});
      _completedIsHidden = !_completedIsHidden;
    });
  }


  _bottomNavigationBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenu(
            isHidden: _completedIsHidden,
            onDelete: _removeCompletedTasks,
            onHide: _hideCompletedTasks,
            onChangeTheme: _changeTheme,
          )
        ],
        title: Text(widget.title),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _bottomNavigationBarTapped,
        items:  const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Задачи")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("Статистика")
          )
        ]
      ),
//      body: _completedIsHidden  && filteredTasks.isEmpty ? EmptyTaskList(isEmptyTask: tasks.isEmpty) :  TaskList(_completedIsHidden ? filteredTasks : tasks, _removeTask),
//      body: _selectedIndex == 0 ? TaskList(_completedIsHidden ? tasks.where((element) => element.isCompleted == false).toList() : tasks, _removeTask) : Text("Empty"),
      floatingActionButton: FloatingActionButton(
          onPressed: _createTodo,
          child: Icon(Icons.add))
      );
    }

    _removeTask(Task task) {
      setState(() {
        tasks.remove(task);
      });
    }

    Future<void> _createTodo() async {
      var todo = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return NewTask("Новое Задание");
          }
      );
      if(todo != null) {
        setState(() {
          tasks.add(Task(todo));
        });
      }
    }

}




