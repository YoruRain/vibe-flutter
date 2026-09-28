import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_flutter/main.dart';
import 'package:vibe_flutter/models/project.dart';
import 'package:vibe_flutter/services/project_api_service.dart';
import 'package:vibe_flutter/services/project_storage.dart';

http.Response jsonResponse(Object? body, int statusCode) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  late List<Map<String, dynamic>> serverProjects;
  late ProjectApiService apiService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    serverProjects = defaultProjects
        .map((project) => project.toJson())
        .toList();
    apiService = ProjectApiService(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return jsonResponse(serverProjects, 200);
        }

        if (request.method == 'POST') {
          final project = Map<String, dynamic>.from(
            jsonDecode(request.body) as Map,
          );
          serverProjects.insert(0, project);
          return jsonResponse(project, 201);
        }

        if (request.method == 'PUT') {
          final project = Map<String, dynamic>.from(
            jsonDecode(request.body) as Map,
          );
          final index = serverProjects.indexWhere(
            (item) => item['id'].toString() == project['id'].toString(),
          );
          serverProjects[index] = project;
          return jsonResponse(project, 200);
        }

        if (request.method == 'DELETE') {
          final id = request.url.pathSegments.last;
          serverProjects.removeWhere((item) => item['id'].toString() == id);
          return http.Response('', 204);
        }

        return http.Response('Not found', 404);
      }),
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(VibeApp(apiService: apiService));
    await tester.pumpAndSettle();
  }

  testWidgets('首页可以创建项目并显示在项目列表', (tester) async {
    await pumpApp(tester);
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
    await pumpApp(tester);

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
    await pumpApp(tester);

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
    await pumpApp(tester);

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
    await pumpApp(tester);

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
    expect(restored!.single.id, 'saved-project');
    expect(restored.single.name, '已保存项目');
  });

  test('ProjectStorage 会保留用户保存的空列表', () async {
    const storage = ProjectStorage();

    await storage.saveProjects([]);
    final restored = await storage.loadProjects();

    expect(restored, isEmpty);
  });

  testWidgets('网络加载失败时可以显示本地缓存', (tester) async {
    const storage = ProjectStorage();
    await storage.saveProjects([defaultProjects.first]);
    final failingService = ProjectApiService(
      client: MockClient((request) async => http.Response('Error', 500)),
    );

    await tester.pumpWidget(
      VibeApp(apiService: failingService, storage: storage),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前显示的是本地缓存，下拉刷新可重新连接服务器。'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('项目'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('我的第一个 App'), findsOneWidget);
  });

  testWidgets('网络和缓存都不可用时可以重新加载', (tester) async {
    final failingService = ProjectApiService(
      client: MockClient((request) async => http.Response('Error', 500)),
    );

    await tester.pumpWidget(VibeApp(apiService: failingService));
    await tester.pumpAndSettle();

    expect(find.text('重新加载'), findsOneWidget);
    expect(find.textContaining('无法连接项目 API'), findsOneWidget);
  });
}
