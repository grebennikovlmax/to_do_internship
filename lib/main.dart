import 'package:flutter/material.dart';

import 'model/task.dart';
import 'task_list.dart';
import 'new_task.dart';
import 'empty_task_list.dart';
import 'popup_menu.dart';
import 'theme_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }

}

class _MyAppState extends State<MyApp> {

  ThemeData theme = ThemeData(
      primaryColor: Color(0xff6202EE),
      accentColor: Color(0xff01A39D),
      backgroundColor: Colors.indigo[100]
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      theme: theme,
      home: MyHomePage(title: "Title",onChangeTheme: _onChangeTheme,activeTheme: theme),
    );
  }

  _onChangeTheme(ThemeData newTheme) {
    setState(() {
      theme = newTheme;
    });
  }
}

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
      body: tasks.isEmpty ? EmptyTaskList() :  TaskList(_completedIsHidden ? tasks.where((element) => element.isCompleted == false).toList() : tasks, _removeTask),
//      body: _selectedIndex == 0 ? TaskList(_completedIsHidden ? tasks.where((element) => element.isCompleted == false).toList() : tasks, _removeTask) : Text("Empty"),
      floatingActionButton: FloatingActionButton(
          onPressed: _createTodo,
          child: Icon(Icons.add))
      );
    }

    _removeTask(int index) {
      setState(() {
        tasks.removeAt(index);
      });
    }

    Future<void> _createTodo() async {
      var todo = await showDialog<Task>(
          context: context,
          builder: (BuildContext context) {
            return NewTask();
          }
      );
      if(todo != null) {
        setState(() {
          tasks.add(todo);
        });
      }
    }

}




