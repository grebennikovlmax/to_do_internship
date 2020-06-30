import 'package:flutter/material.dart';

class CompletionBar extends StatelessWidget {

  final double height;
  final double completionRate;

  CompletionBar({this.height,this.completionRate});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 1),
      tween: Tween(begin: 0,end: completionRate),
      builder: (_, value, __) {
        return CustomPaint(
          size: Size(double.infinity,height),
          painter: CompletionBarPainter(value),
        );
      },
    );
  }

}

class CompletionBarPainter extends CustomPainter {
  final double completion;
  final Color barColor = Color(0xff01A39D);
  Paint paintRect;

  CompletionBarPainter(this.completion) {
    paintRect = Paint()
      ..color = barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
  }


  Paint _paint({Color color, double height}) {
    Paint barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = height;
    return barPaint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset leftOffset = Offset(size.height / 2, 0);
    RRect rect = RRect.fromLTRBR(0, size.height, size.width, 0, Radius.circular(size.height));
    canvas.drawRRect(rect, paintRect);
    canvas.drawLine(size.centerLeft(leftOffset),
        size.centerRight(Offset(-size.height / 2, 0)),
        _paint(color: Colors.white, height: size.height));

    canvas.drawLine(size.centerLeft(leftOffset),
        size.centerLeft(Offset(
            (completion - size.height / 2) < size.height / 2
                ?  size.height / 2
                : completion - size.height / 2, 0)),
        _paint(color: barColor, height: size.height + 1));
  }

  @override
  bool shouldRepaint(CompletionBarPainter oldDelegate) {
    return oldDelegate.completion != completion;
  }

}