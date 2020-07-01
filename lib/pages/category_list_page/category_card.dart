import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:todointernship/model/category.dart';

class CategoryCard extends StatelessWidget {

  final Category category;
  final VoidCallback onTap;

  CategoryCard({this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 13,
                child: ProgressBar(
                    completion: category.completionRate,
                    color: category.theme.primaryColor
                ),
              ),
//              SizedBox(height: 10),
              Spacer(flex: 1),
              Expanded(
                flex: 3,
                child: FittedBox(
                  child: Text(category.name,
                    style: Theme.of(context).textTheme.headline1
                  ),
                ),
              ),
              Spacer(flex: 1),
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: FittedBox(
                  child: Text("${category.amountTask} задач(и)",
                    style: Theme.of(context).textTheme.headline5.copyWith(
                        color: const Color(0xff979797)
                    )
                  ),
                ),
              ),
              Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Color(category.theme.primaryColor).withOpacity(0.3)
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("${category.completedTask} сделано",
                                style: Theme.of(context).textTheme.headline5.copyWith(
                                    color: Color(category.theme.primaryColor)
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(flex: 1),
                      Expanded(
                        flex: 10,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color(0xfffec2c2)
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text("${category.incompletedTask} осталось",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline5.copyWith(
                                      color: const Color(0xffFD3535)
                                  ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}

class ProgressBar extends StatelessWidget {

  final double completion;
  final int color;

  ProgressBar({this.completion, this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 1),
      tween: Tween(begin: 0, end: completion),
      builder: (_, value, __) {
        int progress = (value * 100).toInt();
        return AspectRatio(
          aspectRatio: 1,
          child: CustomPaint (
            painter: ProgressBarPainter(value, color),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Center(
                child: Text("$progress%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(color)
                  ),
                ),
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
  final int color;
  final double strokeWidth = 6;

  ProgressBarPainter(this.completion,this.color);

  Paint _painter(Color color) {
    Paint painter = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..style = PaintingStyle.stroke;
    return painter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var radius = size.height / 2;
    canvas.drawCircle(Offset(radius, radius), radius - strokeWidth, _painter(const Color(0xffC4C4C4)));
    Rect rect = Rect.fromCircle(center: Offset(radius, radius),radius: radius - strokeWidth);
    canvas.drawArc(rect, -pi / 2, -2 * pi * completion, false, _painter(Color(color)));
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.completion != completion;
  }

}

