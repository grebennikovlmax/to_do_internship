import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/pages/task_detail_page/fab_state.dart';

abstract class SliverFabEvent {}

class SliverFabTapEvent implements SliverFabEvent {}

class SliverFabMoveEvent implements SliverFabEvent {

  final double offset;

  SliverFabMoveEvent(this.offset);
}

class SliverFabBlock extends Bloc<SliverFabEvent, FabState> {

  double _fabTop = 124;
  double _fabScale = 1;
  bool _isCompleted;

  SliverFabBlock(this._isCompleted) : super(null);

  @override
  FabState get state => FabState(_fabTop, _fabScale, _isCompleted);

  @override
  Stream<FabState> mapEventToState(SliverFabEvent event) async* {
    if (event is SliverFabTapEvent) {
      _isCompleted = !_isCompleted;
      yield _setFabState();
    } else if ( event is SliverFabMoveEvent){
      yield* _setFabPosition(event.offset);
    }
  }

  Stream<FabState> _setFabPosition(double offset) async* {
    var appBarHeight = 128.0;
    var defaultTop = appBarHeight - 4.0;
    var scaleStart = 96.0;
    var scaleEnd = scaleStart / 2.0;
    _fabScale = 1.0;
    if (offset < defaultTop - scaleStart) {
      _fabScale = 1;
    } else if(offset < defaultTop - scaleEnd) {
      _fabScale = (defaultTop - scaleEnd - offset) / scaleEnd;
    } else {
      _fabScale = 0;
    }
    _fabTop = defaultTop - offset;
    yield _setFabState();
  }

  FabState _setFabState() {
    return FabState(_fabTop, _fabScale, _isCompleted);
  }

}