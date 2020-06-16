import 'package:flutter/material.dart';

enum PopBarMenuItem {hide, delete, theme}

class PopupMenu extends StatelessWidget {

  final VoidCallback onDelete;
  final VoidCallback onHide;
  final Function(BuildContext context) onChangeTheme;
  final bool isHidden;

  PopupMenu({this.isHidden, this.onDelete, this.onHide, this.onChangeTheme});

  _popupMenuButtonPressed(PopBarMenuItem item, BuildContext context) {
    switch(item){
      case PopBarMenuItem.delete:
        onDelete();
        break;
      case PopBarMenuItem.hide:
        onHide();
        break;
      case PopBarMenuItem.theme:
        onChangeTheme(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopBarMenuItem>(
      onSelected: (value) => _popupMenuButtonPressed(value, context),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<PopBarMenuItem>(
              value: PopBarMenuItem.hide,
              child: Text(isHidden ? "Показать выполненые" : "Скрыть выполненные")
          ),
          PopupMenuItem<PopBarMenuItem>(
            value: PopBarMenuItem.delete,
            child: Text("Удалить выполненные"),
          ),
          PopupMenuItem<PopBarMenuItem>(
            value: PopBarMenuItem.theme,
            child: Text("Изменить тему"),
          ),
        ];
      },
    );
  }

}