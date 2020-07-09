import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class ThemePickerBloc extends Bloc<ThemePickerEvent, ThemePickerState> {

  final ThemeListData _themeData;
  List<int> _colorList;
  int _pickedColor;

  ThemePickerBloc(this._themeData, [int pickedColor]) :
      _colorList = _themeData.themes.map((e) => e.backgroundColor).toList(),
      _pickedColor = pickedColor == null ? _themeData.mainTheme.backgroundColor : pickedColor, super(null);

  @override
  ThemePickerState get state => ThemePickerState(_pickedColor, _colorList);

  @override
  Stream<ThemePickerState> mapEventToState(ThemePickerEvent event) async* {
    yield ThemePickerState(event.pickedColor, _colorList);
  }

}