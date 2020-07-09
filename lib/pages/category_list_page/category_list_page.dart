import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'dart:async';
import 'package:todointernship/pages/category_list_page/all_tasks_card.dart';
import 'package:todointernship/pages/category_list_page/category_card.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_bloc.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_event.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_state.dart';
import 'package:todointernship/pages/category_list_page/new_category_dialog.dart';
import 'package:todointernship/theme_bloc.dart';
import 'package:todointernship/widgets/modal_dialog.dart';

class CategoryListPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CategoryListPageState();
  }
}

class _CategoryListPageState extends State<CategoryListPage> {

  CategoryListPageBloc _categoryListBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ignore: close_sinks
    var themeBloc = BlocProvider.of<ThemeBloc>(context);
    var injector = Injector.appInstance;
    _categoryListBloc = CategoryListPageBloc(
      injector.getDependency<TaskRepository>(),
      themeBloc
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryListPageBloc>(
      create: (context) => _categoryListBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text("Оторвись от дивана")
        ),
        body: BlocBuilder(
          bloc: _categoryListBloc,
          builder: (context, state) {
            if(state is LoadingCategoryPageState) return Center(child: CircularProgressIndicator(),);
            return _CategoryList(
              state: state,
              onAddNew: _showNewCategoryDialog,
              onDelete: _onDelete,
            );
          }
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryListBloc.close();
    super.dispose();
  }

  Future<void> _showNewCategoryDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return NewCategoryDialog(
          pageEventSink: _categoryListBloc,
        );
      }
    );
  }

  Future<void> _onDelete(int id) async {
    var choice = await showDialog<bool>(
        context: context,
        builder: (context) {
          return ModalDialog(
            title: 'Удалить список?',
          );
        }
    );
    if(choice ?? false) {
      _categoryListBloc.add(DeleteCategoryEvent(id));
    }
  }
}

class _CategoryList extends StatelessWidget {

  final VoidCallback onAddNew;
  final void Function(int) onDelete;
  final LoadedCategoryPageState state;

  _CategoryList({this.onAddNew, this.state, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
                  child: AllTasksCard(
                    completedTask: state.completedTask,
                    incompletedTask: state.incompletedTask,
                    completionRate: state.complitionTaskRate,
                    amountTask: state.taskAmount,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text("Ветки задач",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      )
                  ),
                ),
              ]),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
              ),
              delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if(!state.categoryList.asMap().containsKey(index)) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _AddButton(
                          onTap: onAddNew,
                        ),
                      );
                    }
                    var themes = BlocProvider.of<ThemeBloc>(context).state;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CategoryCard(
                        onLongPress: () => onDelete(state.categoryList[index].id),
                        category: state.categoryList[index],
                        theme: themes[state.categoryList[index].id],
                      ),
                    );
                  },
                  childCount: state.categoryList.length + 1
              ),
            )
          ]
        )
      );
    }

}


class _AddButton extends StatelessWidget {

  final VoidCallback onTap;

  _AddButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xff01A39D),
              borderRadius: BorderRadius.circular(16)
          ),
          child: Center(
            child: Icon(Icons.add,
              color: const Color(0xffffffff)
            ),
          ),
        ),
      ),
    );
  }
}
