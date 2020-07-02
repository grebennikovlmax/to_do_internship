import 'package:flutter/material.dart';

import 'dart:async';

import 'package:todointernship/pages/category_list_page/all_tasks_card.dart';
import 'package:todointernship/pages/category_list_page/category_card.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_state.dart';
import 'package:todointernship/pages/category_list_page/new_category_dialog.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_bloc.dart';


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
  
  final _categoryListBloc;

  _CategoryListPageState() : _categoryListBloc = CategoryListPageBloc();

  @override
  void dispose() {
    _categoryListBloc.dispose();
    super.dispose();
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
              );
            }
            return Container();
          }
        ),
      ),
    );
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
}

class _CategoryList extends StatelessWidget {

  final VoidCallback onAddNew;
  final LoadedPageState state;

  _CategoryList({this.onAddNew, this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 29, 16, 0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AllTasksCard(
              completedTask: state.completedTask,
              incompletedTask: state.incompletedTask,
              completionRate: state.complitionTaskRate,
              amountTask: state.taskAmount,
            ),
            Divider(height: 20, color:  Colors.transparent),
            Text("Ветки задач",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                )
            ),
            Divider(height: 20, color:  Colors.transparent),
            Expanded(
                child: GridView.builder(
                    itemCount: state.categoryList.length + 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
                    ),
                    itemBuilder: (BuildContext context, index) {
                      if(!state.categoryList.asMap().containsKey(index)) {
                        return _AddButton(
                          onTap: onAddNew,
                        );
                      }
                      return CategoryCard(
                        category: state.categoryList[index],
                      );
                    }
                )
            ),
        ]
      ),
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
