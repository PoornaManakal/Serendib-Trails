import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/LandingPage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Darkened Background Image
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(150),  // Adjust alpha (0-255) for darkness
                BlendMode.darken,
              ),
              child: Image.asset(
                'lib/assets/images/welcome_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Logo and Title Section (Centered near the top)
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'lib/assets/images/logo.png',
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Serendib Trials',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Content (Text and Button)
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Delightful Vacation\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Starts Here.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                
                Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.08),
                  width: screenWidth * 0.8,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Define navigation or further actions
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LandingPage(),
                        ),
                      );
                      
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
