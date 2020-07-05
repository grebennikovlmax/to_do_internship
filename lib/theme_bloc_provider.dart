import 'package:flutter/material.dart';

import 'package:todointernship/theme_bloc.dart';

class ThemeBlocProvider extends InheritedWidget {

  final ThemeBloc themeBloc;

  ThemeBlocProvider({
    this.themeBloc,
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static ThemeBlocProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeBlocProvider>();
  }

  @override
  bool updateShouldNotify(ThemeBlocProvider old) {
    return false;
  }
}