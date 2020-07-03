import 'dart:async';

import 'package:todointernship/data/theme_list_data.dart';

class ThemePickerState {

  final int pickedColor;
  final List<int> colorList;

  ThemePickerState(this.pickedColor, this.colorList);
}

class ThemePickerEvent {
  final int pickedColor;

  ThemePickerEvent(this.pickedColor);
}

class ThemePickerBloc {

  final _themePickerEventStreamController = StreamController<ThemePickerEvent>();
  final _themePickerStateStreamController = StreamController<ThemePickerState>();

  Stream get themePickerStateStream => _themePickerStateStreamController.stream;

  Sink get themePickerEventSink => _themePickerEventStreamController.sink;

  int _pickedColor;

  List<int> _colorList;

  ThemePickerBloc({int pickedColor}) : _pickedColor = pickedColor {
    _initColorList();
    _bindThemeEventListener();
  }

  void _initColorList() {
    var categoryThemeList = ThemeListData.all.themes;
    _colorList = categoryThemeList.map((e) => e.primaryColor).toList();
    _pickedColor ??= _colorList.last;
    _themePickerStateStreamController.add(ThemePickerState(_pickedColor, _colorList));
  }
  void _bindThemeEventListener() {
    _themePickerEventStreamController.stream.listen((event) {
      var color = event.pickedColor;
      _themePickerStateStreamController.add(ThemePickerState(color, _colorList));
    });
  }

  void dispose() {
    _themePickerEventStreamController.close();
    _themePickerStateStreamController.close();
  }
}