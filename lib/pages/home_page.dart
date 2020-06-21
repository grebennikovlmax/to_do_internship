import 'package:flutter/material.dart';

import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/category_theme.dart';



import 'package:todointernship/widgets/all_tasks_card.dart';
import 'package:todointernship/widgets/category_card.dart';

class HomePage extends StatelessWidget {

  List<Category> categories = [];

  HomePage() {
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
            AllTasksCard(),
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
                child: GridView.builder(
                    itemCount: categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      crossAxisCount: 2
                    ),
                    itemBuilder: (BuildContext context, index) {
                      return CategoryCard(categories[index]);
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
