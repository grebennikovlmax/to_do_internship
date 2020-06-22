import 'package:flutter/material.dart';

class CompletionBar extends StatelessWidget {

  final double height;
  final double width;
  final int amountTasks;
  final int completedTasks;

  CompletionBar({this.height,this.width,this.completedTasks,this.amountTasks});

  @override
  Widget build(BuildContext context) {
    double completion = amountTasks == 0 ? 0 : completedTasks / amountTasks * width;
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 1),
      tween: Tween(begin: 0,end: completion),
      builder: (_, value, __) {
        return CustomPaint(
          size: Size(width,height),
          painter: CompletionBarPainter(height,value),
        );
      },
    );
  }

}

class CompletionBarPainter extends CustomPainter {
  final double height;
  final double completion;
  final Color barColor = Color(0xff01A39D);
  Paint paintRect;

  CompletionBarPainter(this.height, this.completion) {
    paintRect = Paint()
      ..color = barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
  }


  Paint _paint({Color color, double offset}) {
    Paint barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = height + offset;
    return barPaint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset leftOffset = Offset(height / 2, 0);
    RRect rect = RRect.fromLTRBR(0, size.height, size.width, 0, Radius.circular(height));
    canvas.drawRRect(rect, paintRect);
    canvas.drawLine(size.centerLeft(leftOffset), size.centerRight(Offset(-height / 2, 0)), _paint(color: Colors.white,offset: 0));
    canvas.drawLine(size.centerLeft(leftOffset), size.centerLeft(Offset((completion - height / 2) < height / 2 ?  height / 2 : completion - height / 2, 0)), _paint(color: barColor, offset: 1));
  }

  @override
  bool shouldRepaint(CompletionBarPainter oldDelegate) {
    return oldDelegate.completion != completion;
  }

}