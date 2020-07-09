import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/theme_list_data.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/empty_task_list.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_bloc.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_state.dart';
import 'package:todointernship/theme_bloc.dart';
import 'package:todointernship/widgets/popup_menu.dart';
import 'package:todointernship/widgets/task_creation_dialog/task_creation_dialog.dart';
import 'package:todointernship/widgets/theme_picker/theme_picker.dart';
import 'package:todointernship/widgets/theme_picker/theme_picker_bloc.dart';
import 'package:todointernship/theme_event.dart';

class TaskListPage extends StatefulWidget {

  final TaskListPageBloc bloc;

  TaskListPage(this.bloc);

  @override
  State<StatefulWidget> createState() {
    return _TaskListPageState();
  }

}

class _TaskListPageState extends State<TaskListPage> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskListPageBloc>(
      create: (context) => widget.bloc,
      child: BlocBuilder(
        bloc: widget.bloc,
        builder: (context, pageState) {
          if(pageState is LoadingTaskListPageState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return _TaskList(
            pageState: pageState,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.bloc.close();
    super.dispose();
  }

}

class _TaskList extends StatelessWidget {

  final LoadedTaskListPageState pageState;

  _TaskList({this.pageState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<ThemeBloc>(context),
      builder: (context, themeSnapshot) {
        return Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: Color(themeSnapshot[pageState.categoryId].backgroundColor),
            appBar: AppBar(
                title: Text(pageState.title),
                backgroundColor: Color(themeSnapshot[pageState.categoryId].primaryColor),
                actions: <Widget>[
                  Builder(
                    builder: (context) {
                      return PopupMenu(
                        isHidden: pageState.isHidden,
                        onDelete: () => _deleteCompletedTask(context),
                        onChangeTheme: () => _showThemePicker(context, themeSnapshot[pageState.categoryId].backgroundColor),
                        onHide: () => _onHideCompleted(context),
                      );
                    }
                  )
                ]
            ),
            body: pageState is EmptyTaskListPageState
                    ? EmptyTaskList((pageState as EmptyTaskListPageState).description)
                    : TaskList((pageState as NotEmptyTaskListPageState).taskList),
            floatingActionButton: FloatingActionButton(
                onPressed: () => _newTask(context),
                child: Icon(Icons.add)
            )
        );
      }
    );
  }

  void _onHideCompleted(BuildContext context) {
    BlocProvider.of<TaskListPageBloc>(context).add(HideTaskEvent());
  }

  void _showThemePicker(BuildContext context, int color) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return _ThemePickerBottomSheet(
              pickedColor: color,
              categoryId: pageState.categoryId,
          );
        }
    );
  }

  void _deleteCompletedTask(BuildContext context) {
    BlocProvider.of<TaskListPageBloc>(context).add(RemoveCompletedEvent());
  }

  void _newTask(BuildContext context) async {
    // ignore: close_sinks
    var sink = BlocProvider.of<TaskListPageBloc>(context);
    await showDialog<Task>(
        context: context,
        builder: (BuildContext context) {
          return TaskCreationDialog(
            edit: false,
            creationEventSink: sink,
          );
        }
    );
  }
}

class _ThemePickerBottomSheet extends StatefulWidget {

  final int pickedColor;
  final int categoryId;

  _ThemePickerBottomSheet({this.pickedColor, this.categoryId});

  @override
  _ThemePickerBottomSheetState createState() => _ThemePickerBottomSheetState();
}

class _ThemePickerBottomSheetState extends State<_ThemePickerBottomSheet> {

  ThemePickerBloc _themePickerBloc;

  @override
  void initState() {
    super.initState();
    _themePickerBloc = ThemePickerBloc(Injector.appInstance.getDependency<ThemeListData>(),widget.pickedColor);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Выбор темы',
              style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18),
            ),
            SizedBox(height: 20),
            ThemePicker(
              onPick: _onPickTheme,
              bloc: _themePickerBloc,
            )
          ],
        ),
      );
  }

  @override
  void dispose() {
    _themePickerBloc.close();
    super.dispose();
  }

  void _onPickTheme(int color) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(widget.categoryId, color));
  }
}
