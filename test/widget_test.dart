import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_flutter/main.dart';

void main() {
  testWidgets('首页可以创建项目并显示在项目列表', (tester) async {
    await tester.pumpWidget(const VibeApp());
    expect(find.text('你好，创造者 👋'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '新建项目').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '测试项目');
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();

    expect(find.text('我的项目'), findsOneWidget);
    expect(find.text('测试项目'), findsOneWidget);
  });

  testWidgets('可以进入详情页并编辑项目', (tester) async {
    await tester.pumpWidget(const VibeApp());

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('项目'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的第一个 App'));
    await tester.pumpAndSettle();
    expect(find.text('项目详情'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '编辑'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '修改后的 App');
    await tester.enterText(fields.at(1), '新的项目备注');
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(find.text('修改后的 App'), findsOneWidget);
    expect(find.text('新的项目备注'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('修改后的 App'), findsOneWidget);
  });

  testWidgets('删除项目前会确认并从列表移除', (tester) async {
    await tester.pumpWidget(const VibeApp());

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('项目'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的第一个 App'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '删除项目'));
    await tester.pumpAndSettle();
    expect(find.text('删除项目？'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '确认删除'));
    await tester.pumpAndSettle();
    expect(find.text('我的第一个 App'), findsNothing);
  });

  testWidgets('项目页面可以按名称实时搜索', (tester) async {
    await tester.pumpWidget(const VibeApp());

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('项目'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '周末');
    await tester.pump();

    expect(find.text('周末灵感清单'), findsOneWidget);
    expect(find.text('我的第一个 App'), findsNothing);
  });
}
