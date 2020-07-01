import 'package:flutter/material.dart';
import 'package:todointernship/pages/category_list_page/category_list_page.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_event.dart';

import 'package:todointernship/widgets/theme_picker/theme_picker.dart';
import 'package:todointernship/widgets/theme_picker/theme_picker_bloc.dart';

class NewCategoryDialog extends StatefulWidget {

  final pageEventSink;

  NewCategoryDialog({this.pageEventSink});

  @override
  _NewCategoryDialogState createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {

  final _key = GlobalKey<FormState>();
  final _themePickerBloc;

  _NewCategoryDialogState() : _themePickerBloc = ThemePickerBloc();

  String text;
  int color;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Создать список',
          style: Theme.of(context).textTheme.headline5,
        ),
        Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                onSaved: (val) => text = val,
                style: Theme.of(context).textTheme.bodyText2,
                validator: _validate,
                decoration: InputDecoration(
                  hintText: 'Введите название списка',
                  border: InputBorder.none,
                ),
              ),
              ThemePicker(
                onPick: _onPickColor,
                height: 24,
                stateStream: _themePickerBloc.themePickerStateStream,
                eventSink: _themePickerBloc.themePickerEventSink,
              ),
              Divider(height: 20, color: Colors.transparent),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    onTap: _onDismiss,
                    child: Text('ОТМЕНА',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  VerticalDivider(),
                  InkWell(
                    onTap: () => _onConfirm(context),
                    child: Text('СОЗДАТЬ',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _themePickerBloc.dispose();
    super.dispose();
  }

  void _onDismiss() {
    Navigator.of(context).pop();
  }

  void _onConfirm(BuildContext context) {
    if(_key.currentState.validate()) {
      _key.currentState.save();
      widget.pageEventSink.add(CreateNewCategoryEvent(text,color));
      Navigator.of(context).pop();
    }
  }

  String _validate(String text) {
    return text.isEmpty ? 'Название списка не может быть пустым' : null;
  }

  void _onPickColor(int color) {
    this.color = color;
  }

}