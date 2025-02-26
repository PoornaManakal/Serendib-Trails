import 'package:flutter/material.dart';

import 'package:serendib_trails/screens/BucketListPage.dart';
import 'package:serendib_trails/screens/Create_a_plan.dart';
import 'package:serendib_trails/screens/Explore.dart';
import 'package:serendib_trails/screens/Home.dart';
import 'package:serendib_trails/screens/SettingPage/setting.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: Color(0xFF0B5739),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("About",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Us?",
                style: TextStyle(
                  color: Color(0xFF0B5739),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "At Serendib Trails, we aim to redefine your travel experience in Sri Lanka. "
                "Whether you're drawn to the serene beaches, lush hill-country, or rich cultural heritage, "
                "we create tailored itineraries that align with your interests and preferences.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                "Our mission is to help you discover the beauty of Sri Lanka seamlessly, "
                "with features like interactive maps, AR landmarks, transportation tips, and budget breakdowns – all in one place.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 20),
              Text(
                "Why choose us?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B5739),
                ),
              ),
              SizedBox(height: 10),
              // Bullet points in a Column instead of Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(
                      "Personalized Itineraries: Tailored trip plans based on your interests, trip duration, and budget."),
                  _buildBulletPoint(
                      "Interactive Maps: Navigate your route with ease using real-time location tracking."),
                  _buildBulletPoint(
                      "Augmented Reality (AR): Preview Sri Lanka's iconic landmarks like Sigiriya Rock and Temple of the Tooth in stunning AR."),
                  _buildBulletPoint(
                      "Budget Transparency: Plan your expenses with our detailed, day-by-day budget breakdown."),
                  _buildBulletPoint(
                      "Trusted Recommendations: Get reliable advice on attractions, accommodations, and transportation options."),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: Text(
                  "Team Serendib Trails",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0B5739),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
     
    );
  }

  // Bullet point builder function
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B5739),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
