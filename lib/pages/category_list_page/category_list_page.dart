import 'package:flutter/material.dart';

import 'dart:async';

import 'package:todointernship/pages/category_list_page/all_tasks_card.dart';
import 'package:todointernship/pages/category_list_page/category_card.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_event.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_state.dart';
import 'package:todointernship/pages/category_list_page/new_category_dialog.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_bloc.dart';
import 'package:todointernship/theme_bloc_provider.dart';
import 'package:todointernship/widgets/modal_dialog.dart';


class CategoryListBlocProvider extends InheritedWidget {

  final CategoryListPageBloc bloc;
  
  const CategoryListBlocProvider({Key key, Widget child, @required this.bloc}) : super(child: child);

  static CategoryListBlocProvider of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CategoryListBlocProvider>();

  @override
  bool updateShouldNotify(CategoryListBlocProvider old) {
    return false;
  }
}

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
    var themeSink = ThemeBlocProvider.of(context).themeBloc.themeEventSink;
    var themeStream = ThemeBlocProvider.of(context).themeBloc.themeStream;
    _categoryListBloc = CategoryListPageBloc(themeSink, themeStream);
  }

  @override
  Widget build(BuildContext context) {
    return CategoryListBlocProvider(
      bloc: _categoryListBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text("Оторвись от дивана")
        ),
        body: StreamBuilder<CategoryListPageState>(
          stream: _categoryListBloc.categoryListPageStateStream,
          builder: (context, snapshot) {
            if(snapshot.data is LoadedPageState) {
              return _CategoryList(
                state: snapshot.data as LoadedPageState,
                onAddNew: _showNewCategoryDialog,
                onDelete: _onDelete,
              );
            }
            return Container();
          }
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryListBloc.dispose();
    super.dispose();
  }

  Future<void> _showNewCategoryDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return NewCategoryDialog(
          pageEventSink: _categoryListBloc.categoryListPageEventSink,
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
      _categoryListBloc.categoryListPageEventSink.add(DeleteCategoryEvent(id));
    }
  }
}

class _CategoryList extends StatelessWidget {

  final VoidCallback onAddNew;
  final void Function(int) onDelete;
  final LoadedPageState state;

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
                    return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CategoryCard(
                              onLongPress: () => onDelete(state.categoryList[index].id),
                              category: state.categoryList[index],
                              theme: state.themes[state.categoryList[index].id],
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
