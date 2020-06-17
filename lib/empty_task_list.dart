import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyTaskList extends StatelessWidget {

  final bool isEmptyTask;
  EmptyTaskList({this.isEmptyTask});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/svg/empty_task_list.svg'),
            Text(isEmptyTask ? "На данный момент в этой ветке нет задач " : "Все задачи выполнены")
          ],
        )
    );
  }
}
