import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:todointernship/model/category.dart';

class CategoryCard extends StatelessWidget {

  final Category category;

  CategoryCard({this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/category_detail',arguments: category.name),
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
                child: ProgressBar(
                    completion: category.completionRate,
                    color: category.theme.primaryColor
                ),
              ),
              SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(category.name,
                  style: Theme.of(context).textTheme.headline1
                ),
              ),
              Text("${category.amountTask} задач(и)",
                style: Theme.of(context).textTheme.headline5.copyWith(
                    color: const Color(0xff979797)
                )
              ),
              SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(category.theme.primaryColor).withOpacity(0.3)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                        child: Text("${category.completedTask} сделано",
                          style: Theme.of(context).textTheme.headline5.copyWith(
                              fontSize:10,
                              color: Color(category.theme.primaryColor)
                          )
                        )
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromRGBO(253, 53, 53, 0.3)
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                          child: Text("${category.incompletedTask} осталось",
                              style: Theme.of(context).textTheme.headline5.copyWith(
                                  fontSize:10,
                                  color: const Color(0xffFD3535)
                              ),
                          ),
                        ),
                      ),
                    )
                  ],
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

  ProgressBarPainter(this.completion,this.color);

  Paint _painter(Color color) {
    Paint painter = Paint()
      ..strokeWidth = 6
      ..color = color
      ..style = PaintingStyle.stroke;
    return painter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var radius = size.height / 2;
//    canvas.drawCircle(Offset(size.height / 2, size.width / 2), size.width / 2, _painter(Color(0xffC4C4C4)));
//    Rect rect = Rect.fromCircle(center: Offset(size.height / 2, size.width / 2),radius: size.width / 2);
//    canvas.drawArc(rect, -pi / 2, -2 * pi * completion, false, _painter(Color(color)));
    canvas.drawCircle(Offset(radius, radius), radius - 6, _painter(Color(0xffC4C4C4)));
    Rect rect = Rect.fromCircle(center: Offset(radius, radius),radius: radius - 6);
    canvas.drawArc(rect, -pi / 2, -2 * pi * completion, false, _painter(Color(color)));
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.completion != completion;
  }

}

