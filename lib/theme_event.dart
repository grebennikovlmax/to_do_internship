abstract class ThemeEvent {}

class LoadThemeEvent implements ThemeEvent {
  final int id;

  LoadThemeEvent(this.id);
}

class SaveThemeEvent implements ThemeEvent {
  final int color;
  final int id;

  SaveThemeEvent(this.color, this.id);
}

class PickThemeEvent implements ThemeEvent {
  final int color;
  final int id;

  PickThemeEvent(this.id, this.color);
}

class RefreshThemeEvent implements ThemeEvent {}

class ChangeThemeEvent implements ThemeEvent {
  final int color;
  final int id;

  ChangeThemeEvent(this.id, this.color);
}