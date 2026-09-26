import 'package:flutter/material.dart';

import '../models/project.dart';
import '../services/project_storage.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_dialog.dart';
import '../widgets/stat_card.dart';
import 'project_detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.storage = const ProjectStorage()});

  final ProjectStorage storage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  bool _isLoading = true;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await widget.storage.loadProjects();
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _projects = List<Project>.from(defaultProjects);
        _isLoading = false;
      });
      _showMessage('读取本地项目失败，已使用默认数据');
    }
  }

  Future<void> _saveProjects() async {
    try {
      await widget.storage.saveProjects(_projects);
    } catch (error) {
      if (!mounted) return;
      _showMessage('保存失败，本次修改可能无法在重启后保留');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addProject() async {
    final project = await showDialog<Project>(
      context: context,
      builder: (context) => const ProjectFormDialog(),
    );

    if (!mounted || project == null) return;
    setState(() {
      _projects.insert(0, project);
      _tab = 1;
    });
    await _saveProjects();
  }

  Future<void> _updateProject(Project updatedProject) async {
    final index = _projects.indexWhere(
      (project) => project.id == updatedProject.id,
    );
    if (index == -1) return;

    setState(() => _projects[index] = updatedProject);
    await _saveProjects();
  }

  Future<void> _openProject(Project project) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailPage(
          project: project,
          onProjectUpdated: _updateProject,
        ),
      ),
    );

    if (!mounted || deleted != true) return;
    setState(() {
      _projects.removeWhere((item) => item.id == project.id);
    });
    await _saveProjects();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
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
      onDestinationSelected: _isLoading
          ? null
          : (index) => setState(() => _tab = index),
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
            child: StatCard(
              value: '${projects.length}',
              label: '项目',
              icon: Icons.folder_copy_outlined,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: StatCard(
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
        ProjectCard(project: project, onTap: () => onOpenProject(project)),
        const SizedBox(height: 12),
      ],
    ],
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
          ProjectCard(
            project: project,
            onTap: () => widget.onOpenProject(project),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
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
              '这是一个 Flutter 学习示例。项目会保存在本地，重新启动 App 后仍然可以继续使用。',
              style: TextStyle(color: Color(0xFF68748B), height: 1.5),
            ),
          ],
        ),
      ),
    ],
  );
}
