import 'package:flutter/material.dart';

import 'pages/home_screen.dart';
import 'services/project_api_service.dart';
import 'services/project_storage.dart';

void main() => runApp(const VibeApp());

class VibeApp extends StatelessWidget {
  const VibeApp({
    super.key,
    this.apiService,
    this.storage = const ProjectStorage(),
  });

  final ProjectApiService? apiService;
  final ProjectStorage storage;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '灵感工作台',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315BDB)),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
    ),
    home: HomeScreen(apiService: apiService, storage: storage),
  );
}
