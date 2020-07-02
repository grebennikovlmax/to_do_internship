import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_detail_page/step_item.dart';

class StepsCard extends StatelessWidget {

  final List<TaskStep> stepList;

  StepsCard({this.stepList});

  @override
  Widget build(BuildContext context) {
//    String formatDate = DateFormat("dd.MM.yyyy").format(TaskInfo.of(context).task.createdDate);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text("Создано: 1",
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
                color: const Color(0xff1A9FFF)
            ),
            title: Text("Добавить шаг",
              style: TextStyle(
                  color: const Color(0xff1A9FFF)
              ),
            ),
            onTap: () => _onNewStep(context),
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

  void _onDelete(int index) async {
    await TaskDatabaseRepository.shared.removeStep(stepList[index].id);
    stepList.removeAt(index);
  }

  void _onNewStep(BuildContext context) async {
    final newStep = TaskStep(
      description: "",
//      taskID: TaskInfo.of(context).task.id
    );
    final id = await TaskDatabaseRepository.shared.saveStep(newStep);
    newStep.id = id;
    stepList.add(newStep);

  }
}