import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/step_item.dart';

class StepsCard extends StatelessWidget {

  final List<TaskStep> stepList;
  final DateTime createdDate;
  final Sink stepListSink;

  StepsCard(this.stepList, this.createdDate, this.stepListSink);

  @override
  Widget build(BuildContext context) {
    String formatDate = DateFormat("dd.MM.yyyy").format(createdDate);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text("Создано: $formatDate",
              style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.6)
              ),
            ),
          ),
          ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: stepList.length,
              itemBuilder: (context, index) {
                return StepItem(
                  onDelete: () => _onDelete(index),
                  step: stepList[index],
                );
              }
          ),
          ListTile(
            leading: Icon(Icons.add,
                color: Color(0xff1A9FFF)
            ),
            title: Text("Добавить шаг",
              style: TextStyle(
                  color: Color(0xff1A9FFF)
              ),
            ),
            onTap: _onNewStep,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 2,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Text("Заметки по задаче..."),
          )
        ]
    );
  }

  void _onDelete(int index) {
    stepList.removeAt(index);
    stepListSink.add(stepList);
  }

  void _onNewStep() {
    stepList.add(TaskStep(""));
    stepListSink.add(stepList);
  }


}