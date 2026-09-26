import 'package:flutter/material.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.note,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String note;
  final IconData icon;
  final Color color;

  Project copyWith({
    String? id,
    String? name,
    String? note,
    IconData? icon,
    Color? color,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'icon': icon.codePoint,
      'color': color.toARGB32(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      note: json['note'] as String,
      icon: _iconFromCodePoint((json['icon'] as num).toInt()),
      color: Color((json['color'] as num).toInt()),
    );
  }
}

IconData _iconFromCodePoint(int codePoint) {
  if (codePoint == Icons.auto_awesome.codePoint) return Icons.auto_awesome;
  if (codePoint == Icons.lightbulb_outline.codePoint) {
    return Icons.lightbulb_outline;
  }
  return Icons.folder_outlined;
}

const defaultProjects = [
  Project(
    id: 'default-first-app',
    name: '我的第一个 App',
    note: '从一个想法开始',
    icon: Icons.auto_awesome,
    color: Color(0xFF315BDB),
  ),
  Project(
    id: 'default-weekend-ideas',
    name: '周末灵感清单',
    note: '把想到的点子记下来',
    icon: Icons.lightbulb_outline,
    color: Color(0xFFE79139),
  ),
];
