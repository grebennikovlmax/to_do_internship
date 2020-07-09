import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todointernship/data/flickr_api_service.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_bloc.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page_state.dart';
import 'package:todointernship/pages/task_detail_page/step_event.dart';
import 'package:todointernship/pages/task_detail_page/step_list_state.dart';
import 'package:todointernship/pages/task_detail_page/steps_card_bloc.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_block.dart';
import 'package:todointernship/pages/task_detail_page/task_detail_page_state.dart';
import 'package:todointernship/pages/task_list_page/task_event.dart';
import 'package:todointernship/pages/task_list_page/task_list_page_bloc.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';
import 'package:todointernship/theme_bloc.dart';
import 'package:todointernship/theme_event.dart';

class MockFlickApiService extends Mock implements FlickrApiService {}
class MockTaskRepository extends Mock implements TaskRepository {}
class MockNotificationManager extends Mock implements PlatformNotificationChannel {}
class MockTaskListPageBloc extends Mock implements TaskListPageBloc {}
class MockSharedPrefManager extends Mock implements SharedPrefManager {}
class MockTask extends Mock implements Task {
  @override
  DateTime get createdDate => DateTime.now();
}
class MockTaskEventSink extends Mock implements Sink<TaskEvent> {}

void main() {

  ThemeBloc themeBloc;
  ImagePickerBloc imagePickerBloc;
  TaskDetailPageBloc taskDetailBloc;
  StepsCardBloc stepsCardBloc;

  setUp(() {
    themeBloc = ThemeBloc(MockSharedPrefManager());
    imagePickerBloc = ImagePickerBloc(MockFlickApiService());
    taskDetailBloc = TaskDetailPageBloc(MockTask(), MockTaskRepository(), MockNotificationManager(), MockTaskEventSink());
    stepsCardBloc = StepsCardBloc(MockTaskRepository(), MockTask());
  });

  tearDown(() {
    themeBloc.close();
    imagePickerBloc.close();
    taskDetailBloc.close();
    stepsCardBloc.close();
  });

  test('theme stream test', () {
    expectLater(
        themeBloc,
        emitsInOrder([{}])
    );
    themeBloc.add(RefreshThemeEvent());
  });

  test('loaded image state', () {
    var t = MockFlickApiService();
    when(t.getRecentImages(1)).thenAnswer((realInvocation) async => ['url']);
    imagePickerBloc = ImagePickerBloc(t);
    expectLater(
      imagePickerBloc.skip(1),
      emitsInOrder([isInstanceOf<LoadingState>(), isInstanceOf<LoadedImageListState>()]),
    );
  });

  test('loaded image state next page', () {
    var t = MockFlickApiService();
    when(t.getRecentImages(1)).thenAnswer((realInvocation) async => ['url']);
    imagePickerBloc = ImagePickerBloc(t);
    expectLater(
      imagePickerBloc.skip(1),
      emitsInOrder([isInstanceOf<LoadingState>(), isInstanceOf<LoadedImageListState>(), isInstanceOf<LoadedImageListState>()]),
    );
    imagePickerBloc.add(NextImagePage());
  });

  test('error image state', () {
    var t = MockFlickApiService();
    when(t.getRecentImages(1)).thenThrow(Exception);
    imagePickerBloc = ImagePickerBloc(t);
    expectLater(
      imagePickerBloc.skip(1),
      emitsInOrder([isInstanceOf<LoadingState>(), isInstanceOf<EmptyImageListState>()]),
    );
    imagePickerBloc.add(NextImagePage());
  });

  test('search not found image state', () {
    var t = MockFlickApiService();
    when(t.searchPhotos(searchText: 'a', page: 1)).thenAnswer((realInvocation) async => []);
    imagePickerBloc = ImagePickerBloc(t);
    expectLater(
      imagePickerBloc.skip(3),
      emitsInOrder([isInstanceOf<LoadingState>(), isInstanceOf<EmptyImageListState>()]),
    );
    imagePickerBloc.add(SearchImageEvent(text: 'a'));
  });

  test('search image state', () {
    var t = MockFlickApiService();
    when(t.searchPhotos(searchText: 'a', page: 1)).thenAnswer((realInvocation) async => ['url', 'url']);
    imagePickerBloc = ImagePickerBloc(t);
    expectLater(
      imagePickerBloc.skip(3),
      emitsInOrder([isInstanceOf<LoadingState>(), isInstanceOf<LoadedImageListState>()]),
    );
    imagePickerBloc.add(SearchImageEvent(text: 'a'));
  });

  test('search image state next page', () {
    var t = MockFlickApiService();
    when(t.searchPhotos(searchText: 'a',page: 1)).thenAnswer((realInvocation) async => ['url', 'url']);
    imagePickerBloc = ImagePickerBloc(t);
    expectLater(
      imagePickerBloc.skip(3),
      emitsInOrder([isInstanceOf<LoadingState>(), isInstanceOf<LoadedImageListState>(), isInstanceOf<LoadedImageListState>()]),
    );
    imagePickerBloc.add(SearchImageEvent(text: 'a'));
    imagePickerBloc.add(NextImagePage());

  });

  test('task detail page state', () {
    expectLater(
        taskDetailBloc,
        emitsInOrder([isInstanceOf<LoadedTaskDetailPageState>()])
    );
  });

  test('crud steps', () {
    var task = MockTask();
    when(task.steps).thenAnswer((realInvocation) => []);
    stepsCardBloc = StepsCardBloc(MockTaskRepository(), task);
    expectLater(
        stepsCardBloc
            .map((event) => (event as LoadedStepListState).stepList.length),
        emitsInOrder([0, 1, 0, 1, 0])
    );
    stepsCardBloc.add(AddStepEvent());
    stepsCardBloc.add(DeleteStepEvent(null));
    stepsCardBloc.add(AddStepEvent());
    stepsCardBloc.add(EditStepEvent(null, null));
  });

  test('complete step', () async {
    var task = MockTask();
    when(task.steps).thenAnswer((realInvocation) => []);
    stepsCardBloc = StepsCardBloc(MockTaskRepository(), task);
    expectLater(
        stepsCardBloc
            .skipWhile((element) => (element as LoadedStepListState).stepList.isEmpty)
            .map((event) {
         return  (event as LoadedStepListState).stepList[0].isCompleted;
        }),
        emitsInOrder([false, true, false])
    );
    stepsCardBloc.add(AddStepEvent());
    await Future.delayed(Duration(milliseconds: 0));
    stepsCardBloc.add(CompletedStepEvent(null));
    stepsCardBloc.add(CompletedStepEvent(null));
  });

  test('task from json', () {
    var createdDate = DateTime.now().millisecondsSinceEpoch;
    var finalDate = DateTime.now().add(Duration(days: 10)).millisecondsSinceEpoch;
    var map = {
      'title': 'name',
      'category_id': 1,
      'id': 2,
      'final_date': finalDate,
      'created_date': createdDate,
    };
    var task = Task.fromMap(map);
    expect('name', task.name);
    expect(1, task.categoryId);
    expect(2, task.id);
    expect(DateTime.fromMillisecondsSinceEpoch(finalDate), task.finalDate);
    expect(null, task.notificationDate);
    expect(DateTime.fromMillisecondsSinceEpoch(createdDate), task.createdDate);
  });

  test('task to Json', () {
    var date = DateTime.now().millisecondsSinceEpoch;
    var task = Task(
      categoryId: 1,
      name: 'name',
      isCompleted: true,
      finalDate: DateTime.fromMillisecondsSinceEpoch(date)
    );
    var map = task.toMap();
    expect(map['title'], task.name);
    expect(map['category_id'], task.categoryId);
    expect(map['is_completed'], 1);
    expect(map['final_date'], date);
    expect(map['created_date'], isInstanceOf<int>());
  });
}
