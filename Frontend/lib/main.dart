import 'package:flutter/material.dart';
import 'screens/welcomepage.dart';

void main() {
  runApp(const SerendibApp());
}

class SerendibApp extends StatelessWidget {
  const SerendibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome', // Start with welcome Screen
      routes: {
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}
