import 'dart:async';

import 'package:todointernship/pages/task_detail_page/fab_state.dart';

class FabTapEvent {}

class SliverFabBloc {
  final _fabPositionStreamController = StreamController<double>();

  final _fabStateStreamController = StreamController<FabState>();
  final _fabTapEvent = StreamController<FabTapEvent>();

  Stream get fabStateStream => _fabStateStreamController.stream;

  Sink get fabPositionSink => _fabPositionStreamController.sink;
  Sink get fabEventSink => _fabTapEvent.sink;

  double _fabTop = 124;
  double _fabScale = 1;
  bool isCompleted;

  SliverFabBloc(this.isCompleted) {
    _setFabState();
    _bindFabPositionListener();
    _bindEventListener();
  }

  void _bindFabPositionListener() {
    _fabPositionStreamController.stream.listen((event) {
      _setFabPosition(event);
    });
  }

  _bindEventListener() {
    _fabTapEvent.stream.listen((event) {
      isCompleted = !isCompleted;
      _setFabState();
    });
  }

  void _setFabPosition(double offset) {
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
    _setFabState();
  }

  void _setFabState() {
    var state = FabState(_fabTop, _fabScale, isCompleted);
    _fabStateStreamController.add(state);
  }

  void dispose() {
    _fabTapEvent.close();
    _fabStateStreamController.close();
    _fabPositionStreamController.close();
  }
}