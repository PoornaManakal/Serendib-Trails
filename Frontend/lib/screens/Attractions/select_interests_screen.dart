import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/main_screen.dart';
import 'package:serendib_trails/screens/Attractions/Attractions.dart';

class SelectInterestsScreen extends StatefulWidget {
  @override
  _SelectInterestsScreenState createState() => _SelectInterestsScreenState();
}

class _SelectInterestsScreenState extends State<SelectInterestsScreen> {
  final List<String> interests = [
    "Culture",
    "Relaxation",
    "Art",
    "Night Life",
    "Hiking",
    "Beach Side",
    "Street Food",
    "Camping",
    "Boat Rides",
    "Cycling",
    "Water Sports",
    "Spiritual Journeys",
    "Historical Tours",
    "Wildlife Safari",
    //"Traditional Arts & Crafts"
  ];

  final List<String> selectedInterests = [];

  void toggleSelection(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else if (selectedInterests.length < 5) {
        selectedInterests.add(interest);
      }
    });
  }

  void continueToAttractions() {
    if (selectedInterests.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AttractionsScreen(selectedInterests: selectedInterests),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one interest.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Select Interests",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF0B5739),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft, // Moves text to the left
                child: Text(
                  "Tell us about your vibe!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B5739),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 16), // Adds padding around the text
              child: Align(
                alignment: Alignment.centerLeft, // Moves text to the left
                child: Text(
                  "Pick up to 5 interests",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(25),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  String interest = interests[index];
                  bool isSelected = selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () => toggleSelection(interest),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFF0B5739)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          interest,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF0B5739),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextButton(
                onPressed: continueToAttractions,
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}