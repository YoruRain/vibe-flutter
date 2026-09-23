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
  final String name;
  final String note;
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
          ),
          _ProjectsContent(projects: _projects, onNewProject: _addProject),
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
  });
  final List<Project> projects;
  final VoidCallback onNewProject;
  final VoidCallback onSeeProjects;

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
        _ProjectCard(project: project),
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
  const _ProjectCard({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
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
                style: const TextStyle(color: Color(0xFF68748B)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProjectsContent extends StatelessWidget {
  const _ProjectsContent({required this.projects, required this.onNewProject});
  final List<Project> projects;
  final VoidCallback onNewProject;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
    children: [
      const Text(
        '我的项目',
        style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      const Text('你的想法，都从这里开始。', style: TextStyle(color: Color(0xFF68748B))),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: onNewProject,
        icon: const Icon(Icons.add),
        label: const Text('新建项目'),
      ),
      const SizedBox(height: 22),
      for (final project in projects) ...[
        _ProjectCard(project: project),
        const SizedBox(height: 12),
      ],
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
