import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyTaskList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _EmptyTaskListState();
  }

}

class _EmptyTaskListState extends State<EmptyTaskList> with SingleTickerProviderStateMixin {

  AnimationController _animationController;
  Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250)
    );
    Tween<Offset> tween = Tween(begin: Offset(0,1), end: Offset.zero);
    _animation = tween.animate(CurvedAnimation(
      curve: Curves.easeOut,
      parent: _animationController
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: <Widget>[
                SvgPicture.asset('assets/svg/empty_layer.svg'),
                ClipOval(
                  child: SlideTransition(
                    position: _animation,
                    child: SvgPicture.asset('assets/svg/empty_task_list.svg'),
                  )
                )
              ],
            ),
            Text("Все задачи выполнены")
          ],
        )
    );
  }
}
