import 'package:flutter/material.dart';

import 'dart:math';

import 'package:todointernship/widgets/completion_bar.dart';
import 'package:todointernship/model/category.dart';


class AllTasksCard extends StatelessWidget {

  final List<Category> categoryList;

  AllTasksCard(this.categoryList);

  @override
  Widget build(BuildContext context) {
    final int allTask = categoryList.fold(0, (previousValue, element) => previousValue + element.taskCount);
    final int completed = categoryList.fold(0, (previousValue, element) => previousValue + element.completedTasks);
    return  Card(
        margin: EdgeInsets.zero,
        color: Color(0xff86A5F5),
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)
        ),
        child: Container(
          margin: EdgeInsets.all(16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Все задания",
                          style: Theme.of(context).textTheme.headline1
                      ),
                      Divider(
                        height: 52,
                        color: Colors.transparent,
                      ),
                      Text("Завершенно $completed задач из $allTask",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Divider(
                        height: 10,
                        color: Colors.transparent,
                      ),
                      CompletionBar(
                          height: 16,
                          width: 176,
                          amountTasks: allTask,
                          completedTasks: completed
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomPaint(
                    size: Size(double.infinity,120),
                    painter: MountPainter(),
                  ),
                )
              ]
          ),
        )
    );
  }

}

class MountPainter extends CustomPainter {

  Paint backgroundPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Color(0xff71E2EF);

  Paint line = Paint()
    ..style = PaintingStyle.fill
    ..color = Color(0xff273B7A)
    ..strokeWidth = 10;

  Paint cloudPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    double sideSize = min(size.width,size.height);
    Path clipPath = Path()
      ..addArc(Rect.fromCircle(center: size.center(Offset.zero),radius: sideSize / 2), 0, 2 * pi);

    canvas.clipPath(clipPath);
    canvas.drawCircle(size.center(Offset.zero), sideSize / 2 , backgroundPaint);
    canvas.drawPath(drawMount(sideSize), line);
    canvas.drawPath(drawCloud(), cloudPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Path drawMount(double height) {
//    List<Offset> points = [
//      Offset(height / 2, 0),
//      Offset(height / 4, height / 2),
//      Offset(height, height / 2)
//    ];
    Path path = Path()
      ..moveTo(height, height)
      ..lineTo(height / 2, 0)
      ..arcToPoint(Offset(height / 2 - 10, 0), radius: Radius.circular(10),clockwise: false)
      ..lineTo(0, height)
      ..close();
    return path;
  }

  Path drawCloud() {
    Path path = Path()
      ..addRect(Rect.fromLTRB(20, -20, 40, -10))
      ..addOval(Rect.fromCircle(center: Offset(30, -20),radius: 10))
      ..addOval(Rect.fromCircle(center: Offset(40, -18),radius: 8))
      ..addOval(Rect.fromCircle(center: Offset(20, -16),radius: 6));

    return path;
  }
}