import 'package:flutter/material.dart';

import '../models/project.dart';
import '../services/project_api_service.dart';
import '../services/project_storage.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_dialog.dart';
import '../widgets/stat_card.dart';
import 'project_detail_page.dart';

enum LoadStatus { initial, loading, success, failure }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.apiService,
    this.storage = const ProjectStorage(),
  });

  final ProjectApiService? apiService;
  final ProjectStorage storage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProjectApiService _apiService;
  int _tab = 0;
  LoadStatus _loadStatus = LoadStatus.initial;
  String? _loadError;
  bool _isSubmitting = false;
  bool _showingCache = false;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ProjectApiService();
    _loadProjects();
  }

  @override
  void dispose() {
    _apiService.close();
    super.dispose();
  }

  Future<void> _loadProjects({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _loadStatus = LoadStatus.loading;
        _loadError = null;
      });
    }

    try {
      final projects = await _apiService.fetchProjects();
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _loadStatus = LoadStatus.success;
        _showingCache = false;
      });
      await _saveCache(projects);
    } catch (error) {
      if (!mounted) return;

      if (!showLoading && _projects.isNotEmpty) {
        _showMessage('刷新失败，请检查 mock REST API 是否正在运行');
        return;
      }

      List<Project>? cachedProjects;
      try {
        cachedProjects = await widget.storage.loadProjects();
      } catch (_) {
        // 缓存损坏时仍展示网络错误与重新加载入口。
      }
      if (!mounted) return;

      if (cachedProjects != null) {
        setState(() {
          _projects = cachedProjects!;
          _loadStatus = LoadStatus.success;
          _showingCache = true;
        });
        _showMessage('网络请求失败，当前显示的是本地缓存');
        return;
      }

      setState(() {
        _loadStatus = LoadStatus.failure;
        _loadError = '无法连接项目 API，请启动 mock REST API 后重试。';
      });
    }
  }

  Future<void> _saveCache(List<Project> projects) async {
    try {
      await widget.storage.saveProjects(projects);
    } catch (error) {
      if (!mounted) return;
      _showMessage('本地缓存保存失败，网络数据仍可正常使用');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addProject() async {
    if (_isSubmitting) return;
    final project = await showDialog<Project>(
      context: context,
      builder: (context) => const ProjectFormDialog(),
    );

    if (!mounted || project == null) return;
    setState(() => _isSubmitting = true);
    try {
      final createdProject = await _apiService.createProject(project);
      if (!mounted) return;
      setState(() {
        _projects.insert(0, createdProject);
        _tab = 1;
        _showingCache = false;
      });
      await _saveCache(_projects);
    } catch (error) {
      if (!mounted) return;
      _showMessage('创建失败，项目没有加入列表');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<Project?> _updateProject(Project updatedProject) async {
    try {
      final savedProject = await _apiService.updateProject(updatedProject);
      final index = _projects.indexWhere(
        (project) => project.id == savedProject.id,
      );
      if (!mounted || index == -1) return null;

      setState(() {
        _projects[index] = savedProject;
        _showingCache = false;
      });
      await _saveCache(_projects);
      return savedProject;
    } catch (error) {
      if (!mounted) return null;
      _showMessage('更新失败，本地项目没有改变');
      return null;
    }
  }

  Future<bool> _deleteProject(String id) async {
    try {
      await _apiService.deleteProject(id);
      if (!mounted) return false;
      setState(() {
        _projects.removeWhere((project) => project.id == id);
        _showingCache = false;
      });
      await _saveCache(_projects);
      return true;
    } catch (error) {
      if (!mounted) return false;
      _showMessage('删除失败，本地项目没有改变');
      return false;
    }
  }

  Future<void> _openProject(Project project) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailPage(
          project: project,
          onProjectUpdated: _updateProject,
          onProjectDeleted: _deleteProject,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadStatus == LoadStatus.initial ||
        _loadStatus == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadStatus == LoadStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: 16),
              Text(_loadError ?? '项目加载失败', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadProjects, child: const Text('重新加载')),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_showingCache)
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF3CD),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: const Text(
              '当前显示的是本地缓存，下拉刷新可重新连接服务器。',
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: [
              _HomeContent(
                projects: _projects,
                isSubmitting: _isSubmitting,
                onNewProject: _isSubmitting ? null : _addProject,
                onSeeProjects: () => setState(() => _tab = 1),
                onOpenProject: _openProject,
              ),
              _ProjectsContent(
                projects: _projects,
                isSubmitting: _isSubmitting,
                onRefresh: () => _loadProjects(showLoading: false),
                onNewProject: _isSubmitting ? null : _addProject,
                onOpenProject: _openProject,
              ),
              const _AboutContent(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: _buildBody()),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _loadStatus != LoadStatus.success
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
    required this.isSubmitting,
    required this.onNewProject,
    required this.onSeeProjects,
    required this.onOpenProject,
  });

  final List<Project> projects;
  final bool isSubmitting;
  final VoidCallback? onNewProject;
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
              label: Text(isSubmitting ? '创建中...' : '新建项目'),
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
    required this.isSubmitting,
    required this.onRefresh,
    required this.onNewProject,
    required this.onOpenProject,
  });

  final List<Project> projects;
  final bool isSubmitting;
  final Future<void> Function() onRefresh;
  final VoidCallback? onNewProject;
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

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          const Text(
            '我的项目',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '你的想法，都从这里开始。',
            style: TextStyle(color: Color(0xFF68748B)),
          ),
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
            label: Text(widget.isSubmitting ? '创建中...' : '新建项目'),
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
      ),
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
              '这是一个 Flutter 学习示例。项目来自 REST API，并会在本地保留最近一次成功加载的缓存。',
              style: TextStyle(color: Color(0xFF68748B), height: 1.5),
            ),
          ],
        ),
      ),
    ],
  );
}
