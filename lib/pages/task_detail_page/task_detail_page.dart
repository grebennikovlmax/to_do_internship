import 'package:flutter/material.dart';

import 'package:todointernship/model/task.dart';
import 'package:todointernship/model/task_image.dart';
import 'package:todointernship/pages/task_detail_page/image_list.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_block.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_state.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_event.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_picker_bloc.dart';
import 'package:todointernship/widgets/task_creation_dialog/date_state.dart';
import 'package:todointernship/pages/task_detail_page/steps_card.dart';
import 'package:todointernship/pages/task_detail_page/fab_state.dart';
import 'package:todointernship/widgets/task_creation_dialog/task_creation_dialog.dart';
import 'package:todointernship/widgets/time_picker_dialog.dart';

import 'date_notification_card.dart';

class TaskDetailBlocProvider extends InheritedWidget {

  final TaskDetailPageBloc bloc;
  final List<TaskStep> stepList;
  final int taskId;
  static TaskDetailBlocProvider of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TaskDetailBlocProvider>();

  TaskDetailBlocProvider({this.bloc,this.stepList, this.taskId, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

}

class TaskDetailPage extends StatefulWidget {

  final TaskDetailPageBloc bloc;

  TaskDetailPage(this.bloc);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskDetailPageState>(
        stream: widget.bloc.taskDetailPageStateStream,
        builder: (context, snapshot) {
          if(snapshot.data is LoadedPageState) {
            var state = snapshot.data as LoadedPageState;
            return TaskDetailBlocProvider(
                bloc: widget.bloc,
                stepList: state.stepList,
                taskId: state.taskId,
                child: _StepList(state: snapshot.data)
            );
          }
          return Container();
        }
    );
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

class _StepList extends StatefulWidget {

  final LoadedPageState state;

  _StepList({this.state});

  @override
  State<StatefulWidget> createState() {
    return _StepListState();
  }


}

class _StepListState extends State<_StepList> {

  final double _appBarHeight = 128;
  TaskDetailPageBloc _taskDetailBloc;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskDetailBloc = TaskDetailBlocProvider.of(context).bloc;
    _scrollController.addListener(() {
      _taskDetailBloc.fabPositionSink.add(_scrollController.offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.state.theme.backgroundColor),
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              StreamBuilder<String>(
                stream: _taskDetailBloc.titleStream,
                initialData: widget.state.title,
                builder: (context, snapshot) {
                    return _TaskDetailSliverAppBar(
                      title: snapshot.data,
                      color: Color(widget.state.theme.primaryColor),
                      taskEditingSink: _taskDetailBloc.taskEditingSink,
                      height: _appBarHeight,
                    );
                  }
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                    Card(
                      margin: EdgeInsets.fromLTRB(16, 28, 16, 10),
                      child: StepsCard(
                        creationDate: widget.state.creationDate
                      )
                    ),
                    DateNotificationCard(
                      finalDate: widget.state.finalDate,
                      notificationDate: widget.state.notificationDate,
                      taskEditingSink: _taskDetailBloc.taskEditingSink,
                    ),
                    SizedBox(height: 30),
                    ImageList(),
                  ]
                )
              )
            ]
          ),
          StreamBuilder<FabState>(
            stream: TaskDetailBlocProvider.of(context).bloc.fabStateStream,
            builder: (context, snapshot) {
              if(!snapshot.hasData) return Container();
              return Positioned(
                top: snapshot.data.top,
                left: 16,
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(snapshot.data.scale),
                  alignment: Alignment.center,
                  child: FloatingActionButton(
                    onPressed: _onCompleted,
                    child: Icon(snapshot.data.isCompleted ? Icons.clear : Icons.check),
                  ),
                ),
              );
            }
          )
        ]
      )
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onCompleted() {
    _taskDetailBloc.taskEditingSink.add(CompletedTaskEvent());
  }

}

enum _TaskDetailPopupMenuItem {update, delete}

class _TaskDetailSliverAppBar extends StatelessWidget {

  final double height;
  final String title;
  final Color color;
  final Sink<TaskEvent> taskEditingSink;

  _TaskDetailSliverAppBar({this.height, this.title, this.taskEditingSink, this.color});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: color,
      pinned: true,
      expandedHeight: height,
      flexibleSpace: FlexibleSpaceBar(
          title: Text(title)
      ),
      actions: <Widget>[
        PopupMenuButton<_TaskDetailPopupMenuItem>(
          onSelected: (item) => _onSelectedMenuItem(item, context),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<_TaskDetailPopupMenuItem>(
                value: _TaskDetailPopupMenuItem.delete,
                child: Text('Удалить'),
              ),
              PopupMenuItem<_TaskDetailPopupMenuItem>(
                value: _TaskDetailPopupMenuItem.update,
                child: Text('Редактировать'),
              )
            ];
          },
        )
      ],
    );
  }

  void _onSelectedMenuItem(_TaskDetailPopupMenuItem item, BuildContext context) {
    switch(item) {
      case _TaskDetailPopupMenuItem.update:
        _updateTask(context);
        break;
      case _TaskDetailPopupMenuItem.delete:
        _deleteTask(context);
    }
  }

  Future<void> _updateTask(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return TaskCreationDialog(
            edit: true,
            name: title,
            creationEventSink: taskEditingSink,
          );
        }
    );
  }

  void _deleteTask(BuildContext context) {
    taskEditingSink.add(RemoveTaskEvent());
    Navigator.of(context).pop();
  }

}



