import 'package:flutter/material.dart';
import 'package:safeplace/screens/home_screen.dart';
import 'package:safeplace/theme/app_theme.dart';

void main() {
  runApp(const SafePlaceApp());
}

class SafePlaceApp extends StatelessWidget {
  const SafePlaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafePlace',
      debugShowCheckedModeBanner: false,
      theme: SafePlaceTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
