import 'package:flutter/material.dart';
import 'screens/welcomepage.dart';
import 'screens/splashscreen.dart';

void main() {
  runApp(const SerendibApp());
}

class SerendibApp extends StatelessWidget {
  const SerendibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Start with splash screen
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}
