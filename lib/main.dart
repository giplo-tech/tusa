import 'package:flutter/material.dart';
import 'package:podpole/auth/auth_gate.dart';
import 'package:podpole/color.dart';
import 'package:podpole/pages/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bottom_navigation_bar/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdXRkdWtvbGZianJrbW1ubHVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg2OTAyODIsImV4cCI6MjA1NDI2NjI4Mn0.mh9aV5H38idYZWwJfbKpDfhHdkOvzvbxM3I7HRKA-jE',
    url: 'https://bsutdukolfbjrkmmnlul.supabase.co',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TUSЭ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(), // Тёмная тема
      themeMode: ThemeMode.dark, // Использовать тёмную тему
      home: AuthGate(),
    );
  }
}