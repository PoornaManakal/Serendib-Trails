import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Background color), // Dark green background
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),

            // Top Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(50), // Apply border radius
              child: Image.asset(
                'assets/icon.png',
                width: 100,
                height: 100,
                fit: BoxFit
                    .cover, // Ensures the image fills the rounded area properly
              ),
            ),

            const SizedBox(height: 50),

            // Header Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Sign Up to continue",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B5739),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // name input 

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Your Name",
                  hintStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  filled: true,
                  fillColor:
                      Colors.white12, // Keeps the semi-transparent background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.black87, width: 1.5), // Default border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.black87, width: 1.5), // Unfocused border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF0B5739),
                        width: 2.0), // Focused border color
                  ),
                ),
                style: const TextStyle(
                    color: Color(0xFF0B5739)), // Text color when typing
                cursorColor: Color(0xFF0B5739), // Cursor color when typing
              ),
            ),

            const SizedBox(height: 20),

            // Email Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  filled: true,
                  fillColor:
                      Colors.white12, // Keeps the semi-transparent background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.black87, width: 1.5), // Default border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.black87, width: 1.5), // Unfocused border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF0B5739),
                        width: 2.0), // Focused border color
                  ),
                ),
                style: const TextStyle(
                    color: Color(0xFF0B5739)), // Text color when typing
                cursorColor: Color(0xFF0B5739), // Cursor color when typing
              ),
            ),

            const SizedBox(height: 20),

            // Password Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  hintText: "Create a Password",
                  hintStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.black87, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.black87, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF0B5739), width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color(0xFF0B5739),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Color(0xFF0B5739)),
                cursorColor:
                    Color(0xFF0B5739), // Changed cursor color to match focus
              ),
            ),

          //password confirm
          const SizedBox(height: 20),

            // Password Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  hintStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.black87, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.black87, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF0B5739), width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color(0xFF0B5739),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Color(0xFF0B5739)),
                cursorColor:
                    Color(0xFF0B5739), // Changed cursor color to match focus
              ),
            ),
            

            const SizedBox(height: 30),

            // Continue Button
            Container(
              width: 300,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF0B5739),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Bottom Sign-up Text
            RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: "Log in",
                    style: const TextStyle(
                      color: Color(0xFF0B5739),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, '/signin');
                     },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
