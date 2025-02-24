import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:serendib_trails/screens/main_screen.dart';

final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";


class TripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  TripDetailScreen({required this.trip});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? suggestedPlaces = trip['suggestedPlaces'] as Map<String, dynamic>?;

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
            "Trip Details",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Interests:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              trip['selectedInterests']?.join(', ') ?? 'No interests available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Suggested Places:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: suggestedPlaces == null || suggestedPlaces.isEmpty
                  ? Center(child: Text('No suggested places available'))
                  : ListView.builder(
                      itemCount: suggestedPlaces.length,
                      itemBuilder: (context, index) {
                        String category = suggestedPlaces.keys.elementAt(index);
                        List<dynamic> places = suggestedPlaces[category] as List<dynamic>;
                        return ExpansionTile(
                          title: Text(category),
                          children: places.map((place) {
                            return Card(
                              margin: EdgeInsets.all(10),
                              elevation: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display the image (if available)
                                  place["photos"] != null && place["photos"].isNotEmpty
                                      ? Image.network(
                                          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place["photos"][0]["photo_reference"]}&key=$googleApiKey",
                                          fit: BoxFit.cover,
                                          height: 180,
                                          width: double.infinity,
                                        )
                                      : Container(), // If no image available, display nothing

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place["name"] ?? "No name",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          place["vicinity"] ?? "No address",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              "Rating: ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Icon(Icons.star, color: Colors.amber, size: 16),
                                            Text(
                                              " ${place["rating"]?.toString() ?? 'N/A'}",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}