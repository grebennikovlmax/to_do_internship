import 'package:flutter/material.dart';

import 'dart:math';

class CategoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  child: ProgressBar(),
                ),
                Container(
                  margin: EdgeInsets.only(top: 13),
                  child: Text("Здоровье",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text("8 задач(и)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff979797)
                    ),
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.teal
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                          child: Text("4 сделано",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: Color(0xff386895)
                            ),
                          )
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Color.fromRGBO(253, 53, 53, 0.51)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                          child: Text("4 осталось",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: Color(0xffFD3535)
                            ),),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class ProgressBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 1),
      tween: Tween(begin: 0, end: 0.75),
      builder: (_, value, __) {
        int progress = (value * 100).toInt();
        return CustomPaint (
          size: Size.infinite,
          painter: ProgressBarPainter(value),
          child: Center(
              child: Text("$progress%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xff3B961B)
                ),
              )
          ),
        );
      },
    );
  }

}

class ProgressBarPainter extends CustomPainter {

  final double completion;

  ProgressBarPainter(this.completion);

  Paint _painter(Color color) {
    Paint painter = Paint()
      ..strokeWidth = 6
      ..color = color
      ..style = PaintingStyle.stroke;
    return painter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.height / 2, size.width / 2), size.width / 2, _painter(Color(0xffC4C4C4)));
    Rect rect = Rect.fromCircle(center: Offset(size.height / 2, size.width / 2),radius: size.width / 2);
    canvas.drawArc(rect, -pi / 2, -2 * pi * completion, false, _painter(Color(0xff3B961B)));
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.completion != completion;
  }

}

