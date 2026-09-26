import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/project.dart';

class ProjectStorage {
  const ProjectStorage();

  static const _projectsKey = 'projects';

  Future<List<Project>> loadProjects() async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = preferences.getString(_projectsKey);

    if (jsonString == null) {
      return List<Project>.from(defaultProjects);
    }

    final jsonList = jsonDecode(jsonString);
    if (jsonList is! List) {
      throw const FormatException('保存的项目数据不是列表');
    }

    return jsonList.map((item) {
      if (item is! Map) {
        throw const FormatException('项目数据格式错误');
      }
      return Project.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<void> saveProjects(List<Project> projects) async {
    final preferences = await SharedPreferences.getInstance();
    final jsonList = projects.map((project) => project.toJson()).toList();
    final saved = await preferences.setString(
      _projectsKey,
      jsonEncode(jsonList),
    );

    if (!saved) {
      throw Exception('项目数据保存失败');
    }
  }
}
