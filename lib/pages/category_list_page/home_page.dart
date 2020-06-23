import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todointernship/data/task_data/task_repository.dart';

import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/pages/category_list_page/all_tasks_card.dart';
import 'package:todointernship/pages/category_list_page/category_card.dart';


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
    Category cat1 = Category("Здоровье",CategoryTheme(backgroundColor:  Colors.yellow.value,primaryColor: Colors.green.value));


    Category cat2 = Category("Работа",CategoryTheme(backgroundColor:  Colors.yellow.value,primaryColor: Colors.green.value));
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
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 29, 16, 0),
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Ветки задач",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                )
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Category>>(
                stream: _categoryListStreamController.stream,
                initialData: categories,
                builder: (context, snapshot) {
                  return GridView.builder(
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (BuildContext context, index) {
                        return CategoryCard(snapshot.data[index], _updateCategoryList);
                      }
                  );
                }
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
