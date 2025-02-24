import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serendib_trails/screens/Home.dart';
import 'package:serendib_trails/screens/LandingPage.dart';
import 'package:serendib_trails/screens/main_screen.dart';
//import 'package:serendib_trails/screens/Home/home_scree.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in, go to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  MainScreen()),
        );
      } else {
        // User is NOT logged in, go to LandingPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B5739), // Green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/logo.png', // Path to logo
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Serendib Trails',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
