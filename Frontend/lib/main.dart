import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/Home.dart';
import 'package:serendib_trails/screens/LandingPage.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';
import 'package:serendib_trails/screens/Login_Screens/SignUp_screen.dart';
import 'screens/welcomepage.dart';
import 'screens/splashscreen.dart';
import 'screens/New_log.dart';
import 'screens/select_interests_screen.dart';
import 'package:firebase_core/firebase_core.dart'; 

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        'LandingPage' :(context) => const LandingPage(),
        '/signup' : (context) => const SignupScreen(),
        '/signin' : (context) => const SigninScreen(),
        '/New_log': (context) => const NewLog(),
        '/select_interests_screen': (context) => SelectInterestsScreen(),
        '/home':(context) => const HomeScreen()
      },
    );
  }
}
