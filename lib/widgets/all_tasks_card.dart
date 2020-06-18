import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:todointernship/widgets/competrion_bar.dart';

class AllTasksCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      child: Card(
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
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Все задания",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 51),
                        child: Text("Завершенно 8 задач из 22",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 6),
                          child: CompletionBar(
                              height: 16,
                              width: 176,
                              amountTasks: 22,
                              completedTasks: 16
                          )
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomPaint(
                    painter: MountPainter(),
                  ),
                )
              ]
            ),
          )
      ),
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
    double sideSize = max(size.width,size.height);
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