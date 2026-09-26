我正在通过逐步扩展一个 Flutter Demo 来学习 Dart 和 Flutter。

当前项目已经实现了：

- 首页、项目页、我的页三个底部 Tab
- Project 数据模型
- 新建项目
- 项目详情页
- 编辑项目
- 删除项目
- 项目搜索
- Navigator.push / Navigator.pop
- 页面之间传递对象和返回结果
- Future / async / await
- StatefulWidget / setState
- TextEditingController
- initState / dispose
- 回调函数
- List / Iterable / where / contains
- nullable 类型
- collection-if / collection-for / spread
- 基本的 Widget 拆分

现在我要进入第三阶段学习。

这一阶段的目标不是继续堆很多 UI 功能，而是把当前“单文件 + 内存数据”的 Demo 改造成一个结构更加接近真实 Flutter 小项目的版本，同时学习 Dart 的数据建模、JSON、本地持久化、异步加载和基本错误处理。

请在当前项目基础上进行以下改造。

一、拆分项目文件结构

目前所有代码都在 main.dart 中。

请将代码拆分成一个适合初学者理解的小型 Flutter 项目结构，例如：

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
    └── project_storage.dart

不要求严格使用上面的文件名，但请保持结构简单、清晰。

不要使用 Clean Architecture、MVVM、Repository Pattern 等复杂架构。

我的目标是理解：

- 为什么代码需要拆文件
- Dart 的 import
- public / private 标识符
- 页面、Widget、Model、数据操作分别适合放在哪里

二、将 Project 改成不可变数据模型

当前 Project 的 name 和 note 可以直接修改。

请将 Project 改为 immutable model：

- 所有字段使用 final
- 增加唯一 id
- 使用构造函数创建对象
- 增加 copyWith 方法
- 编辑项目时不要直接修改原对象，而是创建新的 Project

例如编辑时应该体现类似：

final updatedProject = project.copyWith(
  name: ...,
  note: ...,
);

然后使用新的对象替换 List 中旧的对象。

希望借此学习：

- immutable object
- final
- copyWith
- 对象替换
- identity / id
- List.indexWhere 或类似集合操作

三、为 Project 增加 JSON 序列化

请为 Project 实现：

- toJson()
- fromJson()

可以手写，不使用 json_serializable、freezed 等代码生成工具。

希望能够看到类似：

Map<String, dynamic> toJson()

和：

factory Project.fromJson(Map<String, dynamic> json)

这样的代码。

需要正确处理：

- String
- id
- name
- note
- icon
- color

如果 IconData 或 Color 无法直接写入 JSON，请采用简单、适合学习的方式存储，例如保存 codePoint 或颜色整数值，并在读取时恢复。

希望借此学习：

- Map<String, dynamic>
- JSON 数据结构
- toJson / fromJson
- factory constructor
- 类型转换
- List.map
- encode / decode

四、增加本地数据持久化

让项目列表不再只存在内存中。

请使用一个简单、适合 Flutter 初学者的本地持久化方案保存 Project 列表。

优先选择 shared_preferences；如果采用该方案，可以增加对应依赖。

请新增一个 ProjectStorage 或类似的数据服务类，负责：

Future<List<Project>> loadProjects()

Future<void> saveProjects(List<Project> projects)

HomeScreen 不要自己处理 JSON 编码和 SharedPreferences 的具体细节，而是通过这个类加载和保存数据。

需要满足：

- App 启动时读取本地数据
- 如果本地没有数据，可以使用当前的两个默认项目
- 新建项目后保存
- 编辑项目后保存
- 删除项目后保存
- 重新启动 App 后数据仍然存在

希望借此学习：

- 数据持久化
- SharedPreferences
- service class
- Future
- async / await
- jsonEncode / jsonDecode
- List 与 JSON 的转换

五、处理异步初始化

由于项目数据现在需要异步读取，因此不能再直接在字段初始化时生成完整项目列表。

请设计一个简单清晰的加载流程，例如：

App 启动
→ HomeScreen 创建
→ initState
→ 调用异步 loadProjects()
→ 显示 loading
→ 数据加载完成
→ setState
→ 显示正常页面

可以增加类似：

bool _isLoading

的状态。

加载过程中显示 CircularProgressIndicator。

希望借此学习：

- initState 中如何启动异步操作
- 为什么 initState 本身不能声明为 async
- Future<void>
- loading state
- mounted
- setState
- 异步任务完成后更新 UI

六、增加最基本的错误处理和用户反馈

不要设计复杂错误系统。

只需要：

- 本地读取失败时不要让 App 崩溃
- 保存失败时给用户简单提示
- 可以使用 try / catch
- 可以使用 SnackBar 提示

例如：

try {
  ...
} catch (e) {
  ...
}

希望借此学习：

- try / catch
- Exception
- ScaffoldMessenger
- SnackBar
- 异步操作中的错误处理

七、增加基础表单验证

目前编辑项目时，如果名称为空只是直接 return。

请把新建项目和编辑项目逐步改成比较标准的 Form 写法：

- Form
- GlobalKey<FormState>
- TextFormField
- validator
- FormState.validate()

只需要验证项目名称不能为空即可，不需要复杂规则。

希望借此学习：

- Form
- TextFormField
- validator
- GlobalKey
- FormState
- 表单验证流程

实现时请遵守以下限制：

1. 保留当前 App 的主要 UI 风格，不需要重新设计界面。
2. 不要加入 Provider、Riverpod、Bloc、GetX 等状态管理框架。
3. 继续使用 StatefulWidget + setState。
4. 不要使用 go_router。
5. 不要使用 Hive、SQLite、Drift 等数据库。
6. 除 shared_preferences 外，尽量不要增加第三方依赖。
7. 不要使用 freezed、json_serializable 等代码生成工具。
8. 不要使用 Clean Architecture、MVVM、Repository Pattern 等复杂架构。
9. 不要为了“代码优雅”引入超出当前学习阶段的大量抽象。
10. 优先保证代码容易阅读和学习。

请直接修改现有 Flutter 项目，而不是重新生成一个完全不同的项目。

修改完成后，请运行必要的格式检查和静态分析，确保代码能够正常编译。

最后不要进行长篇教学，只需要给我一份简短总结，包含：

1. 新增和修改了哪些文件；
2. 每个文件主要负责什么；
3. 新增了哪些功能；
4. 为了完成这些功能，引入了哪些新的 Dart / Flutter 知识点；
5. 推荐我按照什么顺序学习这些知识点。

如果你发现某个要求为了实现而会明显增加不必要的复杂度，请优先选择更简单、适合学习的实现方式，并在最后说明。