import 'package:flutter/material.dart';

void main() => runApp(const VibeApp());

class VibeApp extends StatelessWidget {
  const VibeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '灵感工作台',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315BDB)),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
    ),
    home: const HomeScreen(),
  );
}

class Project {
  Project(this.name, this.note, this.icon, this.color);
  String name;
  String note;
  final IconData icon;
  final Color color;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final List<Project> _projects = [
    Project(
      '我的第一个 App',
      '从一个想法开始',
      Icons.auto_awesome,
      const Color(0xFF315BDB),
    ),
    Project(
      '周末灵感清单',
      '把想到的点子记下来',
      Icons.lightbulb_outline,
      const Color(0xFFE79139),
    ),
  ];

  Future<void> _addProject() async {
    var projectName = '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建项目'),
        content: TextField(
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '给你的项目起个名字'),
          onChanged: (value) => projectName = value.trim(),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, projectName),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (!mounted || name == null || name.isEmpty) return;
    setState(() {
      _projects.insert(
        0,
        Project(name, '刚刚创建', Icons.folder_outlined, const Color(0xFF54A89A)),
      );
      _tab = 1;
    });
  }

  Future<void> _openProject(Project project) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailPage(project: project),
      ),
    );

    if (!mounted) return;
    setState(() {
      if (deleted == true) {
        _projects.remove(project);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: _tab,
        children: [
          _HomeContent(
            projects: _projects,
            onNewProject: _addProject,
            onSeeProjects: () => setState(() => _tab = 1),
            onOpenProject: _openProject,
          ),
          _ProjectsContent(
            projects: _projects,
            onNewProject: _addProject,
            onOpenProject: _openProject,
          ),
          const _AboutContent(),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '首页',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: '项目',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    ),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.projects,
    required this.onNewProject,
    required this.onSeeProjects,
    required this.onOpenProject,
  });
  final List<Project> projects;
  final VoidCallback onNewProject;
  final VoidCallback onSeeProjects;
  final ValueChanged<Project> onOpenProject;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
    children: [
      const Text(
        '你好，创造者 👋',
        style: TextStyle(
          fontSize: 29,
          fontWeight: FontWeight.bold,
          color: Color(0xFF18223B),
        ),
      ),
      const SizedBox(height: 6),
      const Text('今天也来把一个想法变成现实吧。', style: TextStyle(color: Color(0xFF68748B))),
      const SizedBox(height: 28),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF315BDB),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.rocket_launch_outlined,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 18),
            const Text(
              '从这里开始你的 App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '先创建一个项目，再慢慢加入页面和功能。',
              style: TextStyle(color: Color(0xFFE1E9FF)),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onNewProject,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF315BDB),
              ),
              icon: const Icon(Icons.add),
              label: const Text('新建项目'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      const Text(
        '今日概览',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '${projects.length}',
              label: '项目',
              icon: Icons.folder_copy_outlined,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: _StatCard(
              value: '1',
              label: '新的开始',
              icon: Icons.bolt_outlined,
            ),
          ),
        ],
      ),
      const SizedBox(height: 30),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '最近项目',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          TextButton(onPressed: onSeeProjects, child: const Text('查看全部')),
        ],
      ),
      const SizedBox(height: 8),
      for (final project in projects.take(2)) ...[
        _ProjectCard(project: project, onTap: () => onOpenProject(project)),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF315BDB)),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Color(0xFF68748B))),
      ],
    ),
  );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onTap});
  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: project.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(project.icon, color: project.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF68748B)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9AA3B6)),
          ],
        ),
      ),
    ),
  );
}

class _ProjectsContent extends StatefulWidget {
  const _ProjectsContent({
    required this.projects,
    required this.onNewProject,
    required this.onOpenProject,
  });
  final List<Project> projects;
  final VoidCallback onNewProject;
  final ValueChanged<Project> onOpenProject;

  @override
  State<_ProjectsContent> createState() => _ProjectsContentState();
}

class _ProjectsContentState extends State<_ProjectsContent> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearch);
  }

  void _updateSearch() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_updateSearch)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProjects = widget.projects.where((project) {
      return project.name.toLowerCase().contains(_query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        const Text(
          '我的项目',
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text('你的想法，都从这里开始。', style: TextStyle(color: Color(0xFF68748B))),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索项目名称',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: '清空搜索',
                    onPressed: _searchController.clear,
                    icon: const Icon(Icons.close),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: widget.onNewProject,
          icon: const Icon(Icons.add),
          label: const Text('新建项目'),
        ),
        const SizedBox(height: 22),
        if (filteredProjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off,
                  size: 48,
                  color: Color(0xFF9AA3B6),
                ),
                const SizedBox(height: 12),
                Text(
                  _query.isEmpty ? '还没有项目' : '没有找到相关项目',
                  style: const TextStyle(color: Color(0xFF68748B)),
                ),
              ],
            ),
          ),
        for (final project in filteredProjects) ...[
          _ProjectCard(
            project: project,
            onTap: () => widget.onOpenProject(project),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.project});
  final Project project;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Future<void> _editProject() async {
    final updatedProject = await showDialog<Project>(
      context: context,
      builder: (context) => _EditProjectDialog(project: widget.project),
    );

    if (!mounted || updatedProject == null) return;
    setState(() {
      widget.project.name = updatedProject.name;
      widget.project.note = updatedProject.note;
    });
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除项目？'),
        content: Text('“${widget.project.name}”删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('项目详情'),
      backgroundColor: const Color(0xFFF7F8FC),
      actions: [
        TextButton.icon(
          onPressed: _editProject,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('编辑'),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.project.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  widget.project.icon,
                  color: widget.project.color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.project.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18223B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.project.note.isEmpty ? '暂无备注' : widget.project.note,
                style: const TextStyle(
                  color: Color(0xFF68748B),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _deleteProject,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('删除项目'),
        ),
      ],
    ),
  );
}

class _EditProjectDialog extends StatefulWidget {
  const _EditProjectDialog({required this.project});
  final Project project;

  @override
  State<_EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<_EditProjectDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _noteController = TextEditingController(text: widget.project.note);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(
      context,
      Project(
        name,
        _noteController.text.trim(),
        widget.project.icon,
        widget.project.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('编辑项目'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          autofocus: true,
          maxLength: 30,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: '项目名称'),
        ),
        TextField(
          controller: _noteController,
          maxLength: 80,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '备注'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: _save, child: const Text('保存')),
    ],
  );
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
    children: [
      const Text(
        '我的',
        style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.waving_hand_outlined,
              color: Color(0xFF315BDB),
              size: 36,
            ),
            SizedBox(height: 16),
            Text(
              '欢迎来到灵感工作台',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '这是一个 Flutter 首页示例。项目数据只保存在当前运行期间，后续可以接入本地存储和真实功能。',
              style: TextStyle(color: Color(0xFF68748B), height: 1.5),
            ),
          ],
        ),
      ),
    ],
  );
}
