import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:serendib_trails/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

class TripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  TripDetailScreen({required this.trip});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? suggestedPlaces = trip['suggestedPlaces'] as Map<String, dynamic>?;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (Route<dynamic> route) => false,
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
                              return GestureDetector(
                                onTap: () {
                                  String placeId = place["place_id"];
                                  String placeName = place["name"];
                                  _openInGoogleMaps(context, placeName, placeId);
                                },
                                child: Card(
                                  margin: EdgeInsets.all(10),
                                  elevation: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          // Display the image (if available)
                                          place["photos"] != null && place["photos"].isNotEmpty
                                              ? Image.network(
                                                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place["photos"][0]["photo_reference"]}&key=$googleApiKey",
                                                  fit: BoxFit.cover,
                                                  height: 180,
                                                  width: double.infinity,
                                                )
                                              : Container(
                                                  height: 180,
                                                  color: Colors.grey,
                                                ), // If no image available, display a grey container
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.bookmark_border, color: Colors.black),
                                                onPressed: () {
                                                  // Handle bookmark action
                                                  _saveFavoritePlace(context, place);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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

  void _openInGoogleMaps(BuildContext context, String placeName, String placeId) async {
    String encodedPlaceName = Uri.encodeComponent(placeName);
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedPlaceName&query_place_id=$placeId";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  Future<void> _saveFavoritePlace(BuildContext context, Map<String, dynamic> place) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final placeId = place['place_id'];

      // Check if the place already exists in the favourite_places collection for the current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('favourite_places')
          .where('userId', isEqualTo: userId)
          .where('placeId', isEqualTo: placeId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Place does not exist, add it to the collection
        await FirebaseFirestore.instance.collection('favourite_places').add({
          'userId': userId,
          'placeId': placeId,
          'name': place['name'],
          'vicinity': place['vicinity'],
          'rating': place['rating'],
          'photoUrl': place['photos'] != null && place['photos'].isNotEmpty
              ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=$googleApiKey"
              : null,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Place added to favourites'), backgroundColor: Colors.green),
        );
      } else {
        // Place already exists, show a message or handle accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Place already added to favourites'), backgroundColor: Colors.orange),
        );
        print('Place already added to favourites');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
    }
  }
}