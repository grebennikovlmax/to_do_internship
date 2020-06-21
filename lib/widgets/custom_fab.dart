import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {

  final bool isCompleted;
  final double offset;
  final double appBarHeight;
  final VoidCallback onPressed;

  CustomFloatingButton(this.isCompleted, this.offset, this.appBarHeight, this.onPressed);


  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: appBarHeight - 4 - offset,
      left: 16,
      child: Transform(
        transform: Matrix4.identity()
          ..scale(calculateScale()),
        alignment: Alignment.center,
        child: FloatingActionButton(
          onPressed: onPressed,
          child: Icon(isCompleted ? Icons.clear : Icons.check),
        ),
      ),
    );
  }

  double calculateScale() {
    final double defaultTop = appBarHeight - 4;
    final double scaleStart = 96;
    final double scaleEnd = scaleStart / 2;
    double scale = 1;
    if (offset < defaultTop - scaleStart) {
      scale = 1;
    } else if(offset < defaultTop - scaleEnd) {
      scale = (defaultTop - scaleEnd - offset) / scaleEnd;
    } else {
      scale = 0;
    }
    return scale;
  }

}