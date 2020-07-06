import 'dart:async';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/category.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_event.dart';
import 'package:todointernship/pages/category_list_page/category_list_page_state.dart';
import 'package:todointernship/theme_event.dart';

class CategoryListPageBloc {

  final repository = TaskDatabaseRepository.shared;
  final sharedPref = SharedPrefManager();
  final Sink<ThemeEvent> themeEventSink;

  final _categoryListPageStateStreamController = StreamController<CategoryListPageState>();
  final _categoryListPageEventStreamController = StreamController<CategoryListPageEvent>();

  Stream get categoryListPageStateStream => _categoryListPageStateStreamController.stream;
  
  Sink get categoryListPageEventSink => _categoryListPageEventStreamController.sink;

  List<Category> _categoryList = [];

  CategoryListPageBloc(this.themeEventSink) {
    _bindEventListener();
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
      }
    });
  }

  Future<void > _loadCategories() async {
    var completedTask = await repository.getAllTask(true);
    var completedTaskCount = completedTask.length;
    var incompletedTask = await repository.getAllTask(false);
    var incompletedTaskCount = incompletedTask.length;
    _categoryList = await repository.getAllCategories();
    await Future.wait(_categoryList.map((category) async {
      themeEventSink.add(LoadThemeEvent(category.id));
      category.incompletedTask = incompletedTask.where((task) => task.categoryId == category.id).length;
      category.completedTask = completedTask.where((task) => task.categoryId == category.id).length;
      category.amountTask = category.incompletedTask + category.completedTask;
      if(category.amountTask != 0) category.completionRate = category.completedTask / category.amountTask;
    }));
    var taskAmount = incompletedTaskCount + completedTaskCount;
    var completionRate = taskAmount == 0 ? 0.0 : completedTaskCount / taskAmount;
    var state = LoadedPageState(completedTaskCount, incompletedTaskCount, completionRate, _categoryList, taskAmount);
    themeEventSink.add(RefreshThemeEvent());
    _categoryListPageStateStreamController.add(state);
  }

  Future<void> _saveCategory(String name, int color) async {
    var category = Category(name: name);
    var id = await repository.saveCategory(category);
    themeEventSink.add(SaveThemeEvent(color,id));
    _loadCategories();
  }

  void dispose() {
    _categoryListPageStateStreamController.close();
    _categoryListPageEventStreamController.close();
  }
}