import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:todointernship/model/category.dart';

class CategoryCard extends StatelessWidget {

  final Category category;
  final void Function(Category) onUpdate;

  CategoryCard(this.category, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/category_detail',arguments: category).then((value) => onUpdate(category)),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                child: ProgressBar(category.completion, category.theme.primaryColor),
              ),
              Divider(
                height: 13,
                color: Colors.transparent,
              ),
              Text(category.name,
                style: Theme.of(context).textTheme.headline1
              ),
              Divider(
                height: 5,
                color: Colors.transparent,
              ),
              Text("${category.taskCount} задач(и)",
                style: Theme.of(context).textTheme.headline5.copyWith(color: Color(0xff979797))
              ),
              Divider(
                height: 7,
                color: Colors.transparent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.teal
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                      child: Text("${category.completedTasks} сделано",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                            fontSize:10,
                            color: Color(0xff386895)
                        )
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
                      child: Text("${category.incompletedTasks} осталось",
                          style: Theme.of(context).textTheme.headline5.copyWith(
                              fontSize:10,
                              color: Color(0xffFD3535)
                          ),
                      ),
                    ),
                  )
                ],
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

  ProgressBar(this.completion, this.color);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 1),
      tween: Tween(begin: 0, end: completion),
      builder: (_, value, __) {
        int progress = (value * 100).toInt();
        return CustomPaint (
          size: Size.infinite,
          painter: ProgressBarPainter(value, color),
          child: Center(
              child: Text("$progress%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(color)
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
    canvas.drawCircle(Offset(size.height / 2, size.width / 2), size.width / 2, _painter(Color(0xffC4C4C4)));
    Rect rect = Rect.fromCircle(center: Offset(size.height / 2, size.width / 2),radius: size.width / 2);
    canvas.drawArc(rect, -pi / 2, -2 * pi * completion, false, _painter(Color(color)));
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.completion != completion;
  }

}

