import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";


class AttractionsScreen extends StatefulWidget {
  final List<String> selectedInterests;
  AttractionsScreen({required this.selectedInterests});

  @override
  _AttractionsScreenState createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  Position? _currentPosition;
  List<dynamic> _places = [];
  Map<String, List<dynamic>> suggestedPlaces = {};
  Set<String> previousSuggestions = {};

  final Map<String, String> categoryKeywords = {
    "Culture": "cultural center|heritage site|historical district",
    "Relaxation": "spa|wellness retreat|meditation center",
    "Art": "art gallery|museum|street art|exhibition",
    "Night Life": "nightlife|bar|club|party|live music",
    "Hiking": "hiking trail|trekking route|nature reserve",
    "Beach Side": "beach|seaside|ocean view|sunset spot",
    "Street Food": "street foods|food cart",
    "Camping": "campground|nature camp|lake camping",
    "Boat Rides": "boat ride|lake cruise|canoeing|yacht tour",
    "Cycling": "cycling path|cycling track",
    "Water Sports": "jet skiing|surfing|scuba diving|rafting",
    "Spiritual Journeys": "temple|monastery|church|mosque",
    "Historical Tours": "historical site|monument|archaeological site",
    "Wildlife Safari": "national park|wildlife sanctuary|animal reserve",
    "Traditional Arts & Crafts": "handicraft market|artisan workshop"
  };

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  String? _pageToken;
  double _offset = 0;

  Future<void> fetchPlaces() async {
    // Clear the previous suggestions on each fetch
    suggestedPlaces.clear();
    previousSuggestions.clear(); // Reset previous suggestions set

    if (_currentPosition != null) {
      _offset +=
          0.01; // Increase the offset every time the regenerate button is clicked

      double newLatitude = _currentPosition!.latitude + _offset;
      double newLongitude = _currentPosition!.longitude + _offset;

      for (String interest in widget.selectedInterests) {
        String keyword = categoryKeywords[interest] ?? "";
        String url =
            "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$newLatitude,$newLongitude&radius=20000&keyword=$keyword&key=$googleApiKey";

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> places = [];

          for (var result in data["results"]) {
            String placeId = result["place_id"];
            if (!previousSuggestions.contains(placeId)) {
              places.add(result);
              previousSuggestions
                  .add(placeId); // Add place_id to avoid repetition
            }
            if (places.length == 3) break; // Limit to one place for now
          }

          if (places.isNotEmpty) {
            suggestedPlaces[interest] = places;
          }
        }
      }
    }

    setState(() {});
  }

  void regeneratePlaces() {
    // Clear the previous suggestions before regenerating
    setState(() {
      suggestedPlaces.clear();
      previousSuggestions.clear(); // Reset previous suggestions set
    });

    fetchPlaces(); // Fetch new places
  }

  void editInterests() {
    Navigator.pop(context);
  }

  void _openInGoogleMaps(String placeName, String placeId) async {
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

  @override
  void initState() {
    super.initState();
    _getCurrentPosition().then((_) => fetchPlaces());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('Nearby Attractions', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF0B5739),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: regeneratePlaces, // Refresh and regenerate places
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: editInterests, // Edit selected interests
            ),
          ],
        ),
        body: _currentPosition == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.selectedInterests.length,
                      itemBuilder: (context, index) {
                        String interest = widget.selectedInterests[index];
                        List<dynamic>? places = suggestedPlaces[interest];

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          elevation: 5,
                          child: ExpansionTile(
                            title: Text(interest),
                            children: places == null
                                ? [ListTile(title: Text('No places found'))]
                                : places.map((place) {
                                    return GestureDetector(
                                      onTap: () {
                                        String placeId = place["place_id"];
                                        String placeName = place["name"];
                                        _openInGoogleMaps(placeName, placeId);
                                      },
                                      child: Card(
                                        margin: EdgeInsets.all(10),
                                        elevation: 5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Display the image (if available)
                                            place["photos"] != null &&
                                                    place["photos"].isNotEmpty
                                                ? Image.network(
                                                    "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place["photos"][0]["photo_reference"]}&key=$googleApiKey",
                                                    fit: BoxFit.cover,
                                                    height: 180,
                                                    width: double.infinity,
                                                  )
                                                : Container(), // If no image available, display nothing

                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    place["name"] ?? "No name",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    place["vicinity"] ??
                                                        "No address",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Rating: ",
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      Icon(Icons.star,
                                                          color: Colors.amber,
                                                          size: 16),
                                                      Text(
                                                        " ${place["rating"]?.toString() ?? 'N/A'}",
                                                        style: TextStyle(
                                                            fontSize: 14),
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
                          ),
                        );
                      },
                    ),
                  )
                ],
              ));
  }
}
