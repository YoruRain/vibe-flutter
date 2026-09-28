import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/project.dart';

class ProjectApiService {
  ProjectApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? defaultBaseUrl;

  static const defaultBaseUrl = String.fromEnvironment(
    'PROJECT_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final http.Client _client;
  final String baseUrl;

  Future<List<Project>> fetchProjects() async {
    final response = await _client.get(Uri.parse('$baseUrl/projects'));
    _throwIfRequestFailed(response);

    final jsonList = jsonDecode(response.body);
    if (jsonList is! List) {
      throw const FormatException('服务器返回的项目数据不是列表');
    }

    return jsonList.map((item) {
      if (item is! Map) {
        throw const FormatException('服务器返回的项目格式错误');
      }
      return Project.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<Project> createProject(Project project) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/projects'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );
    _throwIfRequestFailed(response);
    return _projectFromResponse(response);
  }

  Future<Project> updateProject(Project project) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/projects/${project.id}'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );
    _throwIfRequestFailed(response);
    return _projectFromResponse(response);
  }

  Future<void> deleteProject(String id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/projects/$id'));
    _throwIfRequestFailed(response);
  }

  Project _projectFromResponse(http.Response response) {
    final json = jsonDecode(response.body);
    if (json is! Map) {
      throw const FormatException('服务器返回的项目格式错误');
    }
    return Project.fromJson(Map<String, dynamic>.from(json));
  }

  void _throwIfRequestFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final category = response.statusCode >= 500
        ? '服务器错误'
        : response.statusCode >= 400
        ? '请求错误'
        : 'HTTP 请求失败';
    throw Exception('$category（状态码 ${response.statusCode}）');
  }

  void close() => _client.close();
}
