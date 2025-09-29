import 'package:flutter/material.dart';
import 'pages/keyboard_demo_page.dart';
import 'services/performance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-warm keyboard for optimal first-keystroke performance
  await PerformanceOptimizations.preWarmKeyboard();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multilingual Exam Keyboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const KeyboardDemoPage(),
    );
  }
}

