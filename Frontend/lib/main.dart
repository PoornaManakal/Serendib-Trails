import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/Home.dart';
import 'package:serendib_trails/screens/LandingPage.dart';
import 'package:serendib_trails/screens/Login_Screens/ResetPassword_screen.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';
import 'package:serendib_trails/screens/Login_Screens/SignUp_screen.dart';
import 'package:serendib_trails/screens/main_screen.dart';
import 'package:serendib_trails/screens/Attractions/select_interests_screen.dart';
import 'screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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
        'LandingPage': (context) => const LandingPage(),
        '/signup': (context) => const SignupScreen(),
        '/signin': (context) => const SigninScreen(),
        '/Reset_Password': (context) => const ResetPassword(),
        '/select_interests_screen': (context) => SelectInterestsScreen(),
        '/home': (context) => const HomeScreen(),
        '/main': (context) =>  MainScreen()
      },
    );
  }
}
