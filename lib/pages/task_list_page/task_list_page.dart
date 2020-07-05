import 'package:flutter/material.dart';

import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/task_list_page/empty_task_list.dart';
import 'package:todointernship/pages/task_list_page/hidden_task_event.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_bloc.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_state.dart';
import 'package:todointernship/widgets/popup_menu.dart';
import 'package:todointernship/widgets/task_creation_dialog/task_creation_dialog.dart';
import 'package:todointernship/widgets/theme_picker/theme_picker.dart';
import 'package:todointernship/pages/task_list_page/task_list_state.dart';
import 'package:todointernship/widgets/theme_picker/theme_picker_bloc.dart';
import 'package:todointernship/pages/task_list_page/hidden_task_state.dart';
import 'package:todointernship/theme_event.dart';
import 'package:todointernship/theme_bloc_provider.dart';


class TaskListPage extends StatefulWidget {

  final TaskListPageBloc bloc;

  TaskListPage(this.bloc);

  @override
  State<StatefulWidget> createState() {
    return _TaskListPageState();
  }

}

class TaskListBlocProvider extends InheritedWidget {

  final TaskListPageBloc bloc;
  static TaskListBlocProvider of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskListBlocProvider>();

  TaskListBlocProvider({this.bloc, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

}

class _TaskListPageState extends State<TaskListPage> {

  @override
  Widget build(BuildContext context) {
    return TaskListBlocProvider(
      bloc: widget.bloc,
      child: StreamBuilder<TaskListPageState>(
        stream: widget.bloc.taskListPageStream,
        builder: (context, pageState) {
          if(pageState.data is LoadedPageState) {
            return _TaskList(
              state: pageState.data as LoadedPageState,
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

}

class _TaskList extends StatelessWidget {

  final LoadedPageState state;

  _TaskList({this.state});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, CategoryTheme>>(
      stream: ThemeBlocProvider.of(context).themeBloc.themeStream,
      builder: (context, themeSnapshot) {
        if(!themeSnapshot.hasData) {
          ThemeBlocProvider.of(context).themeBloc.themeEventSink.add(RefreshThemeEvent());
          return Container();
        }
        return Scaffold(
            backgroundColor: Color(themeSnapshot.data[state.categoryId].backgroundColor),
            appBar: AppBar(
                title: Text(state.title),
                backgroundColor: Color(themeSnapshot.data[state.categoryId].primaryColor),
                actions: <Widget>[
                  StreamBuilder<HiddenTaskState>(
                      stream: TaskListBlocProvider.of(context).bloc.hiddenTaskStateStream,
                      initialData: state.hiddenState,
                      builder: (context, snapshot) {
                        return PopupMenu(
                          isHidden: snapshot.data.state,
                          onDelete: () => _deleteCompletedTask(context),
                          onChangeTheme: () => _showThemePicker(context, themeSnapshot.data[state.categoryId].backgroundColor),
                          onHide: () => _onHideCompleted(context),
                        );
                      }
                  )
                ]
            ),
            body: StreamBuilder<TaskListState>(
              stream: TaskListBlocProvider.of(context).bloc.taskListStateStream,
              builder: (context, snapshot) {
                if(snapshot.data is EmptyListState) {
                  var description = (snapshot.data as EmptyListState).description;
                  return EmptyTaskList(description);
                }
                if(snapshot.data is FullTaskListState) {
                  return TaskList((snapshot.data as FullTaskListState).taskList);
                }
                return Container();
              },
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () => _newTask(context),
                child: Icon(Icons.add)
            )
        );
      }
    );
  }

  void _onHideCompleted(BuildContext context) {
    TaskListBlocProvider.of(context).bloc.hideTaskEventSink.add(HideTaskEvent());
  }

  void _showThemePicker(BuildContext context, int color) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return _ThemePickerBottomSheet(
              pickedColor: color,
              categoryId: state.categoryId,
          );
        }
    );
  }

  void _deleteCompletedTask(BuildContext context) {
    TaskListBlocProvider.of(context).bloc.taskEventSink.add(RemoveCompletedEvent());
  }

  void _newTask(BuildContext context) async {
    // ignore: close_sinks
    var sink = TaskListBlocProvider.of(context).bloc.taskEventSink;
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
    _themePickerBloc = ThemePickerBloc(pickedColor: widget.pickedColor);
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
              eventSink: _themePickerBloc.themePickerEventSink,
              stateStream: _themePickerBloc.themePickerStateStream,
            )
          ],
        ),
      );
  }

  @override
  void dispose() {
    _themePickerBloc.dispose();
    super.dispose();
  }

  void _onPickTheme(int color) {
    ThemeBlocProvider.of(context).themeBloc.themeEventSink.add(ChangeThemeEvent(widget.categoryId, color));
  }
}
