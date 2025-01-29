import 'package:flutter/material.dart';
import 'screens/welcomepage.dart';
import 'screens/splashscreen.dart';
import 'screens/LandingPage1.dart';
import 'screens/LandingPage2.dart';
import 'screens/LandingPage3.dart';
import 'screens/New_log.dart';
import 'screens/select_interests_screen.dart';

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
        '/LandingPage1': (context) => const LandingPage1(),
        '/LandingPage2': (context) => const LandingPage2(),
        '/LandingPage3': (context) => const LandingPage3(),
        '/New_log': (context) => const NewLog(),
        '/select_interests_screen': (context) => SelectInterestsScreen(),
      },
    );
  }
}
