我正在学习 Flutter 和 Dart。当前项目已经有一个简单的“灵感工作台”页面，包括：

* 首页、项目页、我的页三个底部 Tab
* Project 数据模型
* 项目列表
* 新建项目功能
* StatefulWidget 和 setState
* StatelessWidget 组件拆分
* showDialog 和 TextField
* IndexedStack 底部页面切换

现在请你在现有代码基础上继续扩展功能，但这次的首要目标不是“做出一个完整产品”，而是让我能够通过修改后的代码继续学习 Dart 和 Flutter。

请新增以下功能：

1. 项目详情页

   * 点击任意 ProjectCard 后，使用 Navigator.push 跳转到 ProjectDetailPage。
   * 详情页显示项目名称、备注、图标等信息。
   * 请不要使用 go_router 等第三方路由框架，只使用 Flutter 原生 Navigator。

2. 编辑项目

   * 在项目详情页增加“编辑”按钮。
   * 点击后弹出一个表单，可以修改项目名称和备注。
   * 保存后返回详情页，并同步更新首页和项目列表中的数据。

3. 删除项目

   * 在详情页增加“删除项目”功能。
   * 删除前使用 AlertDialog 二次确认。
   * 删除成功后返回项目列表。

4. 搜索项目

   * 在“我的项目”页面顶部增加一个搜索框。
   * 可以根据项目名称进行实时过滤。
   * 不需要复杂搜索算法，只实现简单的字符串包含匹配。

在实现时，请遵守以下学习要求：

* 尽量保留现在项目的代码风格和 UI 风格。
* 不要引入 Provider、Riverpod、Bloc、GetX、go_router、Dio、数据库等第三方框架。
* 暂时继续使用 setState 管理状态。
* 代码不要过度工程化，也不要使用 Clean Architecture、Repository Pattern 等复杂架构。
* 如果需要新增类，可以新增 ProjectDetailPage 等少量类。
* 尽量保持代码适合 Flutter 初学者阅读。

我希望通过这次修改重点学习以下知识：

* Navigator.push / Navigator.pop
* 页面之间传递对象
* Future 和 async / await
* Dart 对象的修改与返回
* List 的查找、更新、删除
* nullable 类型
* 回调函数
* TextEditingController
* initState / dispose
* 表单和输入框
* where / contains 等 Dart 集合操作
* setState 与 UI 刷新

请直接修改现有 main.dart。

完成代码后，不要进行长篇教学讲解，只需要在最后简要列出：

1. 新增了哪些功能；
2. 新增或修改了哪些主要类；
3. 哪些代码部分最值得我接下来让 GPT 重点讲解。
