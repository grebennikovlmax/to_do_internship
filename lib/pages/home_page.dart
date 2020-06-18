import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:todointernship/widgets/all_tasks_card.dart';
import 'package:todointernship/widgets/category_card.dart';

class HomePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[200],
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
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      crossAxisCount: 2
                    ),
                    itemBuilder: (BuildContext context, index) {
                      return CategoryCard();
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
