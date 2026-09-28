我正在通过逐步扩展一个 Flutter Demo 来学习 Dart 和 Flutter。

前几个阶段我已经完成了：

- Flutter 基础 Widget 和布局
- StatefulWidget / setState
- 页面导航 Navigator.push / pop
- 页面之间传递数据和返回结果
- Future / async / await
- TextEditingController
- initState / dispose
- 回调函数
- List / Iterable / where / contains
- nullable 类型
- collection-if / collection-for / spread
- 项目拆分为多个文件
- immutable Project model
- final / copyWith
- id / indexWhere
- toJson / fromJson
- factory constructor
- Map<String, dynamic>
- jsonEncode / jsonDecode
- SharedPreferences 本地持久化
- 异步初始化
- loading state
- try / catch
- SnackBar
- Form / GlobalKey<FormState> / TextFormField / validator

现在我要进入第四阶段学习。

这一阶段的核心目标是：

“让 Flutter App 与一个简单 REST API 后端通信，并学习 HTTP 请求、JSON 数据传输、异步网络状态、错误处理和前后端数据流。”

请继续在当前项目基础上改造，不要重新生成一个完全不同的项目。

一、增加一个简单的 API 层

请新增一个类似：

lib/
└── services/
    └── project_api_service.dart

的文件。

使用 Flutter / Dart 常见且适合初学者的方式发送 HTTP 请求。

本阶段优先使用官方常见的 `http` package，例如：

```yaml
http: ^...
```

不要使用 Dio、Retrofit、Chopper 等更复杂的网络库。

请实现类似：

```dart
class ProjectApiService {
  Future<List<Project>> fetchProjects()
  Future<Project> createProject(Project project)
  Future<Project> updateProject(Project project)
  Future<void> deleteProject(String id)
}
```

希望借此学习：

- HTTP client
- GET
- POST
- PUT 或 PATCH
- DELETE
- Uri
- request / response
- statusCode
- response.body
- headers
- Content-Type
- application/json

二、连接一个适合学习的 REST API

这个阶段的重点是 Flutter 前端，因此不要让我额外搭建复杂后端。

请选择一种简单方案：

优先方案：
使用 json-server 或一个非常简单的本地 mock REST API。

例如提供类似：

```text
GET    /projects
POST   /projects
PUT    /projects/:id
DELETE /projects/:id
```

这样的接口。

如果当前项目中还没有 mock server，请为项目增加一个非常简单的 mock backend 目录，例如：

```text
mock_server/
├── db.json
└── README.md
```

并在 README 中说明如何运行：

```bash
npx json-server db.json --port 3000
```

db.json 可以包含几个 Project 示例数据。

请不要使用 Firebase、Supabase、Node.js Express 完整项目、Spring Boot、Django 等复杂后端。

这一阶段的重点是理解 Flutter 如何调用 REST API，而不是后端开发。

三、把项目列表的数据来源从“仅本地”升级为“网络 API”

App 启动时：

```text
HomeScreen 创建
→ 调用 ProjectApiService.fetchProjects()
→ 发送 GET /projects
→ 接收 JSON
→ 转换为 List<Project>
→ setState
→ 显示项目列表
```

需要显示 loading 状态。

如果加载失败：

- 显示简单错误提示
- 保留一个“重新加载”按钮

希望借此学习：

- 网络请求的完整生命周期
- Future
- async / await
- HTTP response
- JSON → Dart Object
- loading / success / error 三种 UI 状态

四、新建项目时调用 POST

当前新建项目后，不要只在本地 List 中插入。

请改为：

```text
用户填写表单
→ 创建 Project
→ POST /projects
→ 后端返回创建后的 Project
→ 添加到 List<Project>
→ UI 更新
```

在请求过程中增加一个简单的 submitting 状态，避免用户重复提交。

如果 POST 失败：

- 不要把项目加入列表
- 使用 SnackBar 提示失败

希望借此学习：

- POST
- Request Body
- jsonEncode
- Content-Type
- 服务端响应
- 请求成功后再修改本地状态

五、编辑项目时调用 PUT 或 PATCH

编辑完成后：

```text
用户修改 Project
→ copyWith 创建新对象
→ PUT /projects/:id
→ 后端返回更新后的 Project
→ 替换 List 中对应项目
→ UI 更新
```

请继续保留 immutable Project 的设计。

不要直接修改旧对象。

希望借此学习：

- REST 中 PUT / PATCH 的基本概念
- URL path parameter
- immutable object
- indexWhere
- 用服务端结果更新本地状态

六、删除项目时调用 DELETE

删除流程改为：

```text
用户确认删除
→ DELETE /projects/:id
→ 服务端成功
→ 从 List 中删除
→ 返回项目列表
```

如果 DELETE 失败：

- 不要删除本地数据
- 显示错误提示

希望借此理解：

“只有服务端操作成功后，前端本地状态才应该同步改变。”

七、增加一个简单的网络状态建模

不要引入 Provider / Riverpod / Bloc。

可以仍然使用 StatefulWidget + setState。

但是请避免只使用一个 `_isLoading` 处理所有状态。

可以设计一个简单 enum，例如：

```dart
enum LoadStatus {
  initial,
  loading,
  success,
  failure,
}
```

也可以使用其他同等级、适合初学者理解的简单方案。

希望借此学习：

- enum
- UI state modeling
- 根据状态渲染不同 Widget
- loading / success / error 状态管理

不要设计复杂 sealed class 或状态管理框架。

八、增加基础 HTTP 错误处理

请在 API service 层对常见情况做最基本判断，例如：

```dart
if (response.statusCode >= 200 &&
    response.statusCode < 300) {
  ...
} else {
  throw Exception(...);
}
```

可以区分：

- 2xx
- 4xx
- 5xx

但不要建立复杂错误体系。

希望借此学习：

- HTTP status code
- Exception
- throw
- try / catch
- API 层错误如何传回 UI 层

九、处理 Android 模拟器访问本机 localhost 的问题

如果使用本机 json-server，请在代码和 README 中明确说明：

Android Emulator 中不能直接使用：

```text
http://localhost:3000
```

而通常需要使用：

```text
http://10.0.2.2:3000
```

如果运行在 Windows 桌面、Web 或其他平台，请说明地址可能不同。

请将 baseUrl 集中定义，例如：

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

不要把 URL 散落在各个函数中。

希望借此学习：

- localhost 的含义
- 模拟器与宿主机网络
- API base URL
- 配置集中管理

十、保留 SharedPreferences，但调整它的角色

第三阶段已经实现了本地持久化。

这一阶段不要完全删除 SharedPreferences。

请让它变成一个简单的“离线缓存”示例：

```text
优先请求 API
↓
请求成功
↓
更新 UI
↓
同时把最新项目保存到 SharedPreferences
```

如果首次 GET 请求失败：

```text
尝试读取 SharedPreferences 缓存
↓
如果有缓存，则显示缓存数据
↓
同时提示“当前显示的是本地缓存”
```

不需要实现复杂离线同步。

不要做：

- 离线编辑后自动同步
- 冲突解决
- 请求队列
- background sync

本阶段只理解：

“网络数据是主要来源，本地数据可以作为简单缓存。”

希望借此学习：

- remote data 与 local cache 的区别
- fallback
- 数据源优先级
- 为什么真实 App 经常同时有网络和本地存储

十一、增加一个简单的刷新功能

在项目列表页面加入：

```dart
RefreshIndicator
```

用户下拉时重新请求：

```text
GET /projects
```

并刷新项目列表。

希望借此学习：

- RefreshIndicator
- Future<void> callback
- 主动重新获取服务器数据

十二、代码结构保持简单

建议最终结构类似：

```text
lib/
├── main.dart
├── models/
│   └── project.dart
├── pages/
│   ├── home_screen.dart
│   └── project_detail_page.dart
├── widgets/
│   ├── project_card.dart
│   └── stat_card.dart
└── services/
    ├── project_api_service.dart
    └── project_storage.dart

mock_server/
├── db.json
└── README.md
```

如果现有结构不同，可以基于现有结构合理调整。

但不要为了架构“标准化”而增加：

```text
repository/
datasource/
usecase/
domain/
presentation/
dependency injection/
```

等额外层级。

十三、实现时请严格遵守以下限制

1. 继续使用 StatefulWidget + setState。
2. 不使用 Provider、Riverpod、Bloc、GetX。
3. 不使用 Dio。
4. 不使用 go_router。
5. 不使用 Retrofit。
6. 不使用 Firebase / Supabase。
7. 不使用 Clean Architecture。
8. 不使用 Repository Pattern。
9. 不使用依赖注入框架。
10. 不实现登录、Token、JWT、OAuth。
11. 不实现 WebSocket。
12. 不实现复杂离线同步。
13. 不重新设计整个 UI。
14. 优先保证代码容易理解，而不是追求生产级架构。
15. 尽量复用我前几个阶段已经学习过的知识。

十四、请特别保留一些“值得学习的代码”

不要为了简化而把所有 HTTP 逻辑封装得完全看不到。

我希望最终项目中能够清楚看到类似：

```dart
final response = await http.get(Uri.parse(...));
```

```dart
jsonDecode(response.body)
```

```dart
jsonEncode(project.toJson())
```

```dart
headers: {
  'Content-Type': 'application/json',
}
```

```dart
if (response.statusCode == 200) {
  ...
}
```

这些代码。

我的目标是学习 HTTP / REST API，而不仅仅是“调用一个封装好的函数”。

十五、完成修改后进行检查

请：

- 运行 dart format
- 运行 flutter analyze
- 如果现有测试能够运行，也请运行相关测试
- 修复由本次修改引入的明显问题

最后不要进行长篇教学。

只需要输出一个简洁总结：

1. 新增或修改了哪些文件；
2. mock REST API 如何启动；
3. App 当前的数据流是什么；
4. 实现了哪些 REST API 操作；
5. 新增了哪些 Dart / Flutter / HTTP 知识点；
6. 推荐我接下来按照什么顺序学习这些知识；
7. 哪几段代码最值得我交给 GPT 深入讲解。