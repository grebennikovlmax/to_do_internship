import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/pages/task_detail_page/image_list.dart';
import 'package:todointernship/pages/task_detail_page/sliver_fab_bloc.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_block.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_state.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_detail_page/steps_card.dart';
import 'package:todointernship/theme_bloc.dart';
import 'package:todointernship/widgets/task_creation_dialog/task_creation_dialog.dart';
import 'package:todointernship/pages/task_detail_page/date_notification_card.dart';

class TaskDetailPage extends StatefulWidget {

  final TaskDetailPageBloc bloc;

  TaskDetailPage(this.bloc);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {

  final double _appBarHeight = 128;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskDetailPageBloc>(
      create: (context) => widget.bloc,
      child: BlocBuilder(
          bloc: widget.bloc,
          builder: (context, pageState) {
            var state = pageState as LoadedTaskDetailPageState;
            var theme = BlocProvider.of<ThemeBloc>(context).state[state.task.categoryId];
            return Scaffold(
              backgroundColor: Color(theme.backgroundColor),
              body: Stack(
                children: <Widget>[
                  CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        _TaskDetailSliverAppBar(
                          title: state.task.name,
                          color: Color(theme.primaryColor),
                          height: _appBarHeight,
                          taskEditingSink: widget.bloc,
                        ),
                        SliverList(
                            delegate: SliverChildListDelegate([
                              Card(
                                  margin: EdgeInsets.fromLTRB(16, 28, 16, 10),
                                  child: StepsCard(state.task)
                              ),
                              DateNotificationCard(
                                finalDate: state.task.finalDate,
                                notificationDate: state.task.notificationDate,
                                taskEditingSink: widget.bloc,
                              ),
                              SizedBox(height: 30),
                              ImageList(
                                  taskId: state.task.id,
                                  categoryId: state.task.categoryId
                              ),
                            ]
                          )
                        )
                      ]
                  ),
                  SliverFab(
                    value: state.task.isCompleted,
                    scrollController: _scrollController,
                  )
                ]
            )
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    widget.bloc.close();
    _scrollController.dispose();
    super.dispose();
  }

}

class SliverFab extends StatefulWidget {

  final bool value;
  final ScrollController scrollController;

  SliverFab({this.value, this.scrollController});

  @override
  SliverFabState createState() => SliverFabState();
}

class SliverFabState extends State<SliverFab> {

  SliverFabBlock _fabBlock;

  @override
  void initState() {
    super.initState();
    _fabBlock = SliverFabBlock(widget.value);
    widget.scrollController.addListener(() {
      _fabBlock.add(SliverFabMoveEvent(widget.scrollController.offset));
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _fabBlock,
        builder: (context, state) {
          return Positioned(
            top: state.top,
            left: 16,
            child: Transform(
              transform: Matrix4.identity()
                ..scale(state.scale),
              alignment: Alignment.center,
              child: FloatingActionButton(
                onPressed: onPressed,
                child: Icon(state.isCompleted ? Icons.clear : Icons.check),
              ),
            ),
          );
        }
    );
  }

  @override
  void dispose() {
    _fabBlock.close();
    super.dispose();
  }

  void onPressed() {
    BlocProvider.of<TaskDetailPageBloc>(context).add(CompletedTaskEvent());
    _fabBlock.add(SliverFabTapEvent());
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



