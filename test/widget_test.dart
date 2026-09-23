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
}
