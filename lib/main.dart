import 'package:flutter/material.dart';

import 'pages/home_screen.dart';

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
