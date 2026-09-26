import 'package:flutter/material.dart';

import '../models/project.dart';
import '../widgets/project_form_dialog.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({
    super.key,
    required this.project,
    required this.onProjectUpdated,
  });

  final Project project;
  final Future<void> Function(Project project) onProjectUpdated;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  Future<void> _editProject() async {
    final updatedProject = await showDialog<Project>(
      context: context,
      builder: (context) => ProjectFormDialog(project: _project),
    );

    if (!mounted || updatedProject == null) return;
    setState(() => _project = updatedProject);
    await widget.onProjectUpdated(updatedProject);
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除项目？'),
        content: Text('“${_project.name}”删除后无法恢复。'),
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
                  color: _project.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(_project.icon, color: _project.color, size: 32),
              ),
              const SizedBox(height: 22),
              Text(
                _project.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18223B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _project.note.isEmpty ? '暂无备注' : _project.note,
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
