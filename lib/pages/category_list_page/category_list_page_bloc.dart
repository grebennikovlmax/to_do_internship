import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/category.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_event.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_state.dart';
import 'package:todointernship/theme_event.dart';

class CategoryListPageBloc extends Bloc<CategoryListPageEvent, CategoryListPageState> {

  final TaskRepository _taskRepository;
  final Sink<ThemeEvent> _themeEventSink;
  List<Category> _categoryList = [];
  int _completedTaskCount;
  int _incompletedTaskCount;
  int _taskAmount;
  double _completionRate;

  CategoryListPageBloc(this._taskRepository, this._themeEventSink) : super(LoadingCategoryPageState()) {
    this.add(UpdatePageEvent());
  }

  @override
  Stream<CategoryListPageState> mapEventToState(CategoryListPageEvent event) async* {
    if(event is CreateNewCategoryEvent) {
      yield* _saveCategory(event);
    } else if (event is DeleteCategoryEvent) {
      _deleteCategory(event);
    } else if (event is UpdatePageEvent) {
      yield await _loadCategories();
    }
  }

  Future<LoadedCategoryPageState> _loadCategories() async {
    var completedTask = await _taskRepository.getAllTask(true);
    _completedTaskCount = completedTask.length;
    var incompletedTask = await _taskRepository.getAllTask(false);
    _incompletedTaskCount = incompletedTask.length;
    _categoryList = await _taskRepository.getAllCategories();
    await Future.wait(_categoryList.map((category) async {
      _themeEventSink.add(LoadThemeEvent(category.id));
      category.incompletedTask = incompletedTask.where((task) => task.categoryId == category.id).length;
      category.completedTask = completedTask.where((task) => task.categoryId == category.id).length;
      category.amountTask = category.incompletedTask + category.completedTask;
      if(category.amountTask != 0) category.completionRate = category.completedTask / category.amountTask;
    }));
    await Future.delayed(Duration(milliseconds: 200));
    _taskAmount = _incompletedTaskCount + _completedTaskCount;
    _completionRate = _taskAmount == 0 ? 0.0 : _completedTaskCount / _taskAmount;
    return LoadedCategoryPageState(_completedTaskCount, _incompletedTaskCount, _completionRate,_categoryList, _taskAmount);
  }

  Stream<CategoryListPageState> _saveCategory(CreateNewCategoryEvent event) async* {
    var category = Category(name: event.name);
    var id = await _taskRepository.saveCategory(category);
    category.id = id;
    _categoryList.add(category);
    _themeEventSink.add(SaveThemeEvent(event.color,id));
    yield LoadedCategoryPageState(_completedTaskCount, _incompletedTaskCount, _completionRate,_categoryList, _taskAmount);
  }

  void _deleteCategory(DeleteCategoryEvent event) async {
    _categoryList.removeWhere((element) => element.id == event.categoryId);
    _taskRepository.removeCategory(event.categoryId);
    _themeEventSink.add(DeleteThemeEvent(event.categoryId));
    add(UpdatePageEvent());
  }

}