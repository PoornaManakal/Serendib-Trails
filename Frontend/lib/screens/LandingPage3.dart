import 'package:flutter/material.dart';
//import 'package:serendib_trails/screens/LandingPage1.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';

class LandingPage3 extends StatelessWidget {
  const LandingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: const Color(0xFF0B5739),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Image Container
                    Container(
                      width: screenWidth * 0.9, // Make image width responsive
                      height: screenHeight *
                          0.4, // Adjust height based on screen size
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('lib/assets/images/landing3.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title Text
                    Column(
                      children: [
                        Text(
                          'Life is short and the',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth *
                                0.06, // Adjust based on screen width
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'world is ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'wide',
                                style: TextStyle(color: Color(0xFFFF7029)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'At Friends tours and travel, we customize reliable and trustworthy educational tours to destinations all over the world',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.05, // Responsive font size
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, size: 8, color: Colors.white),
                        SizedBox(width: 5),
                        Icon(Icons.circle, size: 8, color: Colors.white),
                        SizedBox(width: 5),
                        Icon(Icons.circle, size: 15, color: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),

              // Next Button
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenHeight *
                      0.05, // Adjust button margin based on screen height
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigation logic
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const SigninScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Slide from right
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02), // Responsive padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Adjust button text size
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B5739),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

