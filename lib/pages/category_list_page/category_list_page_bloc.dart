import 'dart:async';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_event.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_state.dart';
import 'package:todointernship/theme_event.dart';

class CategoryListPageBloc {

  final repository = TaskDatabaseRepository.shared;
  final sharedPref = SharedPrefManager();
  final Sink<ThemeEvent> themeEventSink;
  final Stream<Map<int, CategoryTheme>> themeStream;

  final _categoryListPageStateStreamController = StreamController<CategoryListPageState>();
  final _categoryListPageEventStreamController = StreamController<CategoryListPageEvent>();

  Stream get categoryListPageStateStream => _categoryListPageStateStreamController.stream;

  Sink get categoryListPageEventSink => _categoryListPageEventStreamController.sink;

  List<Category> _categoryList = [];
  Map<int, CategoryTheme> _themes = {};
  int _completedTaskCount;
  int _incompletedTaskCount;
  int _taskAmount;
  double _completionRate;

  CategoryListPageBloc(this.themeEventSink, this.themeStream) {
    _bindEventListener();
    _bindThemeEventListener();
    _loadCategories();
  }

  void _bindEventListener() {
    _categoryListPageEventStreamController.stream.listen((event) {
      switch(event.runtimeType) {
        case CreateNewCategoryEvent:
          var createEvent = event as CreateNewCategoryEvent;
          _saveCategory(createEvent.name, createEvent.color);
          break;
        case UpdatePageEvent:
          _loadCategories();
          break;
        case DeleteCategoryEvent:
          _deleteCategory(event);
          break;
      }
    });
  }

  Future<void > _loadCategories() async {
    var completedTask = await repository.getAllTask(true);
    _completedTaskCount = completedTask.length;
    var incompletedTask = await repository.getAllTask(false);
    _incompletedTaskCount = incompletedTask.length;
    _categoryList = await repository.getAllCategories();
    await Future.wait(_categoryList.map((category) async {
      themeEventSink.add(LoadThemeEvent(category.id));
      category.incompletedTask = incompletedTask.where((task) => task.categoryId == category.id).length;
      category.completedTask = completedTask.where((task) => task.categoryId == category.id).length;
      category.amountTask = category.incompletedTask + category.completedTask;
      if(category.amountTask != 0) category.completionRate = category.completedTask / category.amountTask;
    }));
    _taskAmount = _incompletedTaskCount + _completedTaskCount;
    _completionRate = _taskAmount == 0 ? 0.0 : _completedTaskCount / _taskAmount;
    themeEventSink.add(RefreshThemeEvent());
  }

  void _bindThemeEventListener() {
    themeStream.listen((event) {
      _themes = event;
      _updateState();
    });
  }

  void _updateState() {
    var state = LoadedPageState(_completedTaskCount, _incompletedTaskCount, _completionRate,_categoryList, _taskAmount, _themes);
    _categoryListPageStateStreamController.add(state);
  }

  Future<void> _saveCategory(String name, int color) async {
    var category = Category(name: name);
    var id = await repository.saveCategory(category);
    category.id = id;
    _categoryList.add(category);
    themeEventSink.add(SaveThemeEvent(color,id));
  }

  void _deleteCategory(DeleteCategoryEvent event) {
    _categoryList.removeWhere((element) => element.id == event.categoryId);
    repository.removeCategory(event.categoryId);
    themeEventSink.add(DeleteThemeEvent(event.categoryId));
    _loadCategories();
  }

  void dispose() {
    _categoryListPageStateStreamController.close();
    _categoryListPageEventStreamController.close();
  }
}