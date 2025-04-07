import 'package:flutter/material.dart';
import 'ArViewer.dart';


void main() {
  runApp(AugmentedReality());
}

class AugmentedReality extends StatelessWidget {
  const AugmentedReality({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30), // Space from top
              const Text(
                "Historical Landmarks",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Explore the rich history of famous landmarks and discover their significance over time.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // List of landmark buttons
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    landmarkButton(
                      context,
                      imagePath: 'lib/temple_tooth.jpeg',
                      title: "Temple of Tooth",
                      description:
                      "The Temple of the Tooth Relic in Kandy, Sri Lanka, is a sacred Buddhist temple...",
                    ),
                    landmarkButton(
                      context,
                      imagePath: 'lib/ldambulla_temple.jpg',
                      title: "Dambulla Cave Temple",
                      description:
                      "Dambulla Cave Temple is a UNESCO World Heritage Site featuring intricate murals...",
                    ),
                    landmarkButton(
                      context,
                      imagePath: 'lib/sigiriya.jpg',
                      title: "Sigiriya",
                      description:
                      "Sigiriya is an ancient rock fortress in Sri Lanka with stunning frescoes...",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom button widget for landmarks
Widget landmarkButton(
    BuildContext context, {
      required String imagePath,
      required String title,
      required String description,
    }) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 15),
    child: Column(
      children: [
        InkWell(
          onTap: () {
            // Navigate to the landmark details screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LandmarkDetailsScreen(
                  title: title,
                  imagePath: imagePath,
                  description: description,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // AR Button
        ElevatedButton(
          onPressed: () {
            // Navigate to the AR viewer screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArViewer(
                  modelPath: 'assets/${title.toLowerCase().replaceAll(' ', '_')}.glb',
                ),
              ),
            );
          },
          child: const Text("View in AR"),
        ),
      ],
    ),
  );
}

// New screen to show landmark details
class LandmarkDetailsScreen extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;

  const LandmarkDetailsScreen({
    required this.title,
    required this.imagePath,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
