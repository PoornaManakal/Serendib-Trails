import 'package:flutter/material.dart';

class SelectInterestsScreen extends StatefulWidget {
  @override
  _SelectInterestsScreenState createState() => _SelectInterestsScreenState();
}

class _SelectInterestsScreenState extends State<SelectInterestsScreen> {
  // List of interests
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
    "Wildlife Safari"
        "Traditional Arts & Crafts "
  ];

  // Selected interests
  final List<String> selectedInterests = [];

  // Method to toggle interest selection
  void toggleSelection(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else if (selectedInterests.length < 5) {
        selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            Text(
              "Tell us about your vibe!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Pick up to 5 interests.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: interests.map((interest) {
                  final isSelected = selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () => toggleSelection(interest),
                    child: Chip(
                      label: Text(
                        interest,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.green.shade900,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? const Color.fromARGB(255, 29, 74, 31)
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle continue action
                },
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 10, 73, 25),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
