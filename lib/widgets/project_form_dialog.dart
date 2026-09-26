import 'package:flutter/material.dart';

import '../models/project.dart';

class ProjectFormDialog extends StatefulWidget {
  const ProjectFormDialog({super.key, this.project});

  final Project? project;

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _noteController = TextEditingController(text: widget.project?.note);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final note = _noteController.text.trim();
    final project = widget.project;

    final result = project == null
        ? Project(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: name,
            note: note.isEmpty ? '刚刚创建' : note,
            icon: Icons.folder_outlined,
            color: const Color(0xFF54A89A),
          )
        : project.copyWith(name: name, note: note);

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_isEditing ? '编辑项目' : '新建项目'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            autofocus: true,
            maxLength: 30,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: '项目名称'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入项目名称';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _noteController,
            maxLength: 80,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '备注（可选）'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: _submit, child: Text(_isEditing ? '保存' : '创建')),
    ],
  );
}
