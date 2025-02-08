import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack( // Use Stack to overlay content
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                buildLandingContent(screenWidth, screenHeight, 'lib/assets/images/landing1.jpg', 'Life is short and the', 'world is ', 'wide', 'At Friends tours and travel, we customize reliable and trustworthy educational tours.'),
                buildLandingContent(screenWidth, screenHeight, 'lib/assets/images/landing2.jpg', 'Traveling opens up', 'endless ', 'possibilities', 'Discover new cultures, cuisines, and friendships while exploring beautiful destinations.'),
                buildLandingContent(screenWidth, screenHeight, 'lib/assets/images/landing3.jpg', 'Your adventure starts', 'right ', 'now', 'Plan your next trip with us and create unforgettable memories.'),
              ],
            ),
            Positioned( // Position the bottom content
              bottom: 0,
              left: 0,
              right: 0,
              child: buildBottomNavigationBar(screenWidth, screenHeight),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar(double screenWidth, double screenHeight) {
   return Container( // Added Container for background color
      color: const Color(0xFF0B5739), // Match the background color
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 15 : 8,
                  height: _currentPage == index ? 15 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.orange : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.05, left: 16, right: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Handle final action like navigation to home screen
                    Navigator.pushNamed(context, '/signin');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentPage < 2 ? 'Next' : 'Get Started',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B5739),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  
Widget buildLandingContent(double screenWidth, double screenHeight, String imagePath, String title1, String title2, String highlight, String description) {
  return Container(
    color: const Color(0xFF0B5739),
    child: Column(
      children: [
        Expanded( // This is the key!
          flex: 1, // Optional: You can adjust the flex value
          child: Align( // Align content to the top
            alignment: Alignment.topCenter,
            child: SingleChildScrollView( // Added for scrollability if content overflows
              child: Padding(
                padding: const EdgeInsets.only(top: 80), // Adjust this value to control the spacing
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Important for the inner Column
                  children: [
                    Container( // Image Container
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column( // Title Column
                      children: [
                        Text(
                          title1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: title2, style: const TextStyle(color: Colors.white)),
                              TextSpan(text: highlight, style: const TextStyle(color: Color(0xFFFF7029))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding( // Description Padding
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}