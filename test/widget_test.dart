import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_flutter/main.dart';
import 'package:vibe_flutter/models/project.dart';
import 'package:vibe_flutter/services/project_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('首页可以创建项目并显示在项目列表', (tester) async {
    await tester.pumpWidget(const VibeApp());
    await tester.pumpAndSettle();
    expect(find.text('你好，创造者 👋'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '新建项目').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '测试项目');
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();

    expect(find.text('我的项目'), findsOneWidget);
    expect(find.text('测试项目'), findsOneWidget);
  });

  testWidgets('可以进入详情页并编辑项目', (tester) async {
    await tester.pumpWidget(const VibeApp());
    await tester.pumpAndSettle();

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
    final fields = find.byType(TextFormField);
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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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

  testWidgets('新建项目时会验证名称不能为空', (tester) async {
    await tester.pumpWidget(const VibeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '新建项目').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pump();

    expect(find.text('请输入项目名称'), findsOneWidget);
  });

  test('Project 可以复制并完成 JSON 往返转换', () {
    const original = Project(
      id: 'project-1',
      name: '原项目',
      note: '原备注',
      icon: Icons.auto_awesome,
      color: Color(0xFF315BDB),
    );

    final updated = original.copyWith(name: '新项目');
    final restored = Project.fromJson(updated.toJson());

    expect(original.name, '原项目');
    expect(updated.id, original.id);
    expect(restored.name, '新项目');
    expect(restored.note, original.note);
    expect(restored.icon.codePoint, original.icon.codePoint);
    expect(restored.color.toARGB32(), original.color.toARGB32());
  });

  test('ProjectStorage 可以保存和读取项目列表', () async {
    const storage = ProjectStorage();
    const projects = [
      Project(
        id: 'saved-project',
        name: '已保存项目',
        note: '会在重启后恢复',
        icon: Icons.folder_outlined,
        color: Color(0xFF54A89A),
      ),
    ];

    await storage.saveProjects(projects);
    final restored = await storage.loadProjects();

    expect(restored, hasLength(1));
    expect(restored.single.id, 'saved-project');
    expect(restored.single.name, '已保存项目');
  });

  test('ProjectStorage 会保留用户保存的空列表', () async {
    const storage = ProjectStorage();

    await storage.saveProjects([]);
    final restored = await storage.loadProjects();

    expect(restored, isEmpty);
  });
}
