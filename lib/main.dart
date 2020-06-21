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


//  _changeTheme(BuildContext context) {
//    showBottomSheet(
//        context: context,
//        builder: (BuildContext context) {
//          return ThemePicker(widget.activeTheme, _onPickNewColor);
//        });
//  }
//
//  _onPickNewColor(ThemeData theme) {
//    widget.onChangeTheme(theme);
//  }
//
//  _hideCompletedTasks() {
//    setState(() {
//      filteredTasks = _completedIsHidden ? [] : tasks.where((element) => element.isCompleted == false).toList() ;
//      filteredTasks.forEach((element) {print(element.name);});
//      _completedIsHidden = !_completedIsHidden;
//    });
//  }
//
//
//  _bottomNavigationBarTapped(int index) {
//    setState(() {
//      _selectedIndex = index;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    return Scaffold(
//      appBar: AppBar(
//        actions: <Widget>[
//          PopupMenu(
//            isHidden: _completedIsHidden,
//            onDelete: _removeCompletedTasks,
//            onHide: _hideCompletedTasks,
//            onChangeTheme: _changeTheme,
//          )
//        ],
//        title: Text(widget.title),
//      ),
//      backgroundColor: Theme.of(context).backgroundColor,
//      bottomNavigationBar: BottomNavigationBar(
//        currentIndex: _selectedIndex,
//        onTap: _bottomNavigationBarTapped,
//        items:  const <BottomNavigationBarItem>[
//          BottomNavigationBarItem(
//            icon: Icon(Icons.home),
//            title: Text("Задачи")
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(Icons.settings),
//            title: Text("Статистика")
//          )
//        ]
//      ),
////      body: _completedIsHidden  && filteredTasks.isEmpty ? EmptyTaskList(isEmptyTask: tasks.isEmpty) :  TaskList(_completedIsHidden ? filteredTasks : tasks, _removeTask),
////      body: _selectedIndex == 0 ? TaskList(_completedIsHidden ? tasks.where((element) => element.isCompleted == false).toList() : tasks, _removeTask) : Text("Empty"),
//      floatingActionButton: FloatingActionButton(
//          onPressed: _createTodo,
//          child: Icon(Icons.add))
//      );
//    }
//
//    _removeTask(Task task) {
//      setState(() {
//        tasks.remove(task);
//      });
//    }
//
//    Future<void> _createTodo() async {
//      var todo = await showDialog<String>(
//          context: context,
//          builder: (BuildContext context) {
//            return NewTask("Новое Задание");
//          }
//      );
//      if(todo != null) {
//        setState(() {
//          tasks.add(Task(todo));
//        });
//      }
//    }
//
//}
//
//
//
//
