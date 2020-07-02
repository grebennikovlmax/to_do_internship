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

  final ThemePickerBloc _themePickerBloc;

  _TaskListPageState() : _themePickerBloc = ThemePickerBloc();

  @override
  Widget build(BuildContext context) {
    return TaskListBlocProvider(
      bloc: widget.bloc,
      child: StreamBuilder<TaskListPageState>(
        stream: widget.bloc.taskListPageStream,
        builder: (context, pageState) {
          if(pageState.data is LoadedPageState) {
            return _TaskList(
              themePickerBloc: _themePickerBloc,
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
    _themePickerBloc.dispose();
    super.dispose();
  }

}

class _TaskList extends StatelessWidget {

  final LoadedPageState state;
  final ThemePickerBloc themePickerBloc;

  _TaskList({this.state, this.themePickerBloc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategoryTheme>(
      stream: TaskListBlocProvider.of(context).bloc.themeStream,
      initialData: state.theme,
      builder: (context, themeSnapshot) {
        return Scaffold(
            backgroundColor: Color(themeSnapshot.data.backgroundColor),
            appBar: AppBar(
                title: Text(state.title),
                backgroundColor: Color(themeSnapshot.data.primaryColor),
                actions: <Widget>[
                  StreamBuilder<HiddenTaskState>(
                      stream: TaskListBlocProvider.of(context).bloc.hiddenTaskStateStream,
                      initialData: state.hiddenState,
                      builder: (context, snapshot) {
                        return PopupMenu(
                          isHidden: snapshot.data.state,
                          onDelete: () => _deleteCompletedTask(context),
                          onChangeTheme: () => _showThemePicker(context),
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

  void _showThemePicker(BuildContext context) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Выбор темы',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18),
                ),
                SizedBox(height: 20),
                ThemePicker(
                  onPick: (index) => _onPickTheme(index, context),
                  eventSink: themePickerBloc.themePickerEventSink,
                  stateStream: themePickerBloc.themePickerStateStream,
                )
              ],
            ),
          );
        }
    );
  }

  void _deleteCompletedTask(BuildContext context) {
    TaskListBlocProvider.of(context).bloc.taskEventSink.add(RemoveCompletedEvent());
  }

  void _onPickTheme(int index, BuildContext context) {
    TaskListBlocProvider.of(context).bloc.pickerThemeSink.add(index);
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
