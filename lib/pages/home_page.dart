import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/widgets/all_tasks_card.dart';
import 'package:todointernship/widgets/category_card.dart';


class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {

  List<Category> categories = [];

  StreamController<List<Category>> _categoryListStreamController;

  @override
  void initState() {
    super.initState();
    Task newTask = Task("Дописать тз на стражировку");
    var step1 = TaskStep("Написать часть про главный экран");
    var step2 = TaskStep("Очень сложный длинный шаг, на который легко наткнуться, сложно выполнить и невозможно забыть");
    newTask.steps.add(step1);
    newTask.steps.add(step2);
    Category cat1 = Category("Здоровье",CategoryTheme(Color(0xff6002ee).value,Color(0xff90ee02).value));
    cat1.newTask = Task("Дорисовать дизайн");
    cat1.newTask = Task("Дописать план");
    cat1.newTask = newTask;

    Category cat2 = Category("Работа",CategoryTheme(Colors.yellow.value,Colors.green.value));
    cat2.newTask = Task("Спать");
    cat2.newTask = Task("Есть");

    categories.add(cat1);
    categories.add(cat2);
    _categoryListStreamController = StreamController.broadcast();
  }

  @override
  void dispose() {
    _categoryListStreamController.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Оторвись от дивана")
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(16, 29, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<List<Category>>(
              initialData: categories,
              stream: _categoryListStreamController.stream,
              builder: (context, snapshot) {
                return AllTasksCard(snapshot.data);
              }
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text("Ветки задач",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                )
              )
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 18),
                child: StreamBuilder<List<Category>>(
                  stream: _categoryListStreamController.stream,
                  initialData: categories,
                  builder: (context, snapshot) {
                    return GridView.builder(
                        itemCount: snapshot.data.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          crossAxisCount: 2
                        ),
                        itemBuilder: (BuildContext context, index) {
                          return CategoryCard(snapshot.data[index], _updateCategoryList);
                        }
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _updateCategoryList(Category category) {
    final int index = categories.indexWhere((element) => element.name == category.name);
    categories[index] = category;
    _categoryListStreamController.add(categories);
  }
}
