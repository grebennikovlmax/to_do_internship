import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:todointernship/model/category.dart';
import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/model/task.dart';
import 'package:todointernship/pages/category_list_page/category_card.dart';
import 'package:todointernship/pages/task_list_page/task_item.dart';
import 'package:todointernship/widgets/custom_checkbox.dart';

class MockTaskStep extends Mock implements TaskStep {}
class MockTask extends Mock implements Task {}
class MockCategory extends Mock implements Category {}

class MockTheme extends Mock implements CategoryTheme {

  @override
  int get backgroundColor => 1;

  @override
  int get primaryColor => 1;
}

void main() {

  MockTask mockTask;
  MockCategory mockCategory;

  setUp(() {
    mockCategory = MockCategory();
    mockTask = MockTask();
  });

  testWidgets('task item', (tester) async {
    when(mockTask.name).thenAnswer((realInvocation) => 'test');
    when(mockTask.isCompleted).thenAnswer((realInvocation) => true);
    when(mockTask.steps).thenAnswer((realInvocation) => []);
    await tester.pumpWidget(appWidget(TaskItem(task: mockTask)));
    var text = find.text(mockTask.name);
    var finder = find.byType(CustomCheckBox);
    CustomCheckBox checkBox = tester.widget(finder);
    var checkboxValue = checkBox.value;
    var listTileFinder = find.byType(ListTile);
    ListTile listTile = tester.widget(listTileFinder);
    expect(text, findsOneWidget);
    expect(checkboxValue, true);
    expect(listTile.subtitle, null);
  });

  testWidgets('task item subtitle', (tester) async {
    when(mockTask.name).thenAnswer((realInvocation) => 'test');
    when(mockTask.isCompleted).thenAnswer((realInvocation) => false);
    when(mockTask.steps).thenAnswer((realInvocation) => [null, null]);
    await tester.pumpWidget(appWidget(TaskItem(task: mockTask)));
    var finder = find.byType(ListTile);
    ListTile listTile = tester.widget(finder);
    expect(listTile.subtitle, isInstanceOf<Text>());
  });

  testWidgets('category card', (tester) async {
    when(mockCategory.name).thenAnswer((realInvocation) => 'test');
    when(mockCategory.completedTask).thenAnswer((realInvocation) => 1);
    when(mockCategory.incompletedTask).thenAnswer((realInvocation) => 1);
    when(mockCategory.amountTask).thenAnswer((realInvocation) => 2);
    when(mockCategory.completionRate).thenAnswer((realInvocation) => 0.78);
    await tester.pumpWidget(appWidget(CategoryCard(category: mockCategory, theme: MockTheme())));
    var nameText = find.text(mockCategory.name);
    var amoutText = find.text('${mockCategory.amountTask} задач(и)');
    await tester.pump(Duration(seconds: 1));
    var completionText = find.text('78%');
    var completedText = find.text('${mockCategory.completedTask} сделано');
    var incompletedText = find.text('${mockCategory.incompletedTask} осталось');
    expect(nameText, findsOneWidget);
    expect(amoutText, findsOneWidget);
    expect(completionText, findsOneWidget);
    expect(completedText, findsOneWidget);
    expect(incompletedText, findsOneWidget);
  });
}


Widget appWidget(Widget widget) {
  return MaterialApp(
    home: Scaffold(
      body: widget,
    ),
  );
}