import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  TextEditingController locationController = TextEditingController();
  List<dynamic> _autocompleteResults = [];
  double? inputLatitude;
  double? inputLongitude;
  FocusNode _focusNode = FocusNode();

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

  Future<void> _fetchAutocompleteSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _autocompleteResults = [];
      });
      return;
    }

    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&components=country:LK&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _autocompleteResults = data["predictions"];
      });
    }
  }

  Future<void> _convertPlaceIdToCoordinates(String placeId) async {
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["results"].isNotEmpty) {
        setState(() {
          inputLatitude = data["results"][0]["geometry"]["location"]["lat"];
          inputLongitude = data["results"][0]["geometry"]["location"]["lng"];
          _autocompleteResults = []; // Clear suggestions after selection
          locationController.clear(); // Clear input field after selection
        });
        fetchPlaces(); // Fetch attractions after getting new coordinates
      }
    }
  }

  String? _pageToken;
  double _offset = 0;

  Future<void> fetchPlaces() async {
    suggestedPlaces.clear();
    previousSuggestions.clear();

    double? latitude;
    double? longitude;

    if (inputLatitude != null && inputLongitude != null) {
      latitude = inputLatitude;
      longitude = inputLongitude;
    } else {
      latitude = _currentPosition?.latitude;
      longitude = _currentPosition?.longitude;
    }

    if (latitude != null && longitude != null) {
      _offset +=
          0.01; // Increase the offset every time the regenerate button is clicked

      double newLatitude = latitude + _offset;
      double newLongitude = longitude + _offset;

      for (String interest in widget.selectedInterests) {
        String keyword = categoryKeywords[interest] ?? "";
        String url =
            "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$newLatitude,$newLongitude&radius=10000&keyword=$keyword&key=$googleApiKey";

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> places = [];

          for (var result in data["results"]) {
            String placeId = result["place_id"];
            if (!previousSuggestions.contains(placeId)) {
              places.add(result);
              previousSuggestions.add(placeId);
            }
            if (places.length == 3) break;
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

   Future<void> _saveTripToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference trips = FirebaseFirestore.instance.collection('trips');
      try {
        await trips.add({
          'userId': user.uid,
          'selectedInterests': widget.selectedInterests,
          'suggestedPlaces': suggestedPlaces,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save trip: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Unfocus the input field when tapping outside
      },
      child: Scaffold(
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
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: locationController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  labelText: "Enter Location",
                                  labelStyle: TextStyle(color: Color(0xFF0B5739)),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF0B5739),
                                    width: 2.0,
                                  ),
                                ),
                                  suffixIcon: Icon(Icons.search),
                                ),
                                onChanged: _fetchAutocompleteSuggestions,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.my_location,
                                  color: Color(0xFF0B5739)),
                              onPressed: () {
                                setState(() {
                                  inputLatitude = null;
                                  inputLongitude = null;
                                });
                                fetchPlaces();
                              },
                            ),
                          ],
                        ),
                        if (_autocompleteResults.isNotEmpty)
                          Container(
                            color: Colors.white,
                            child: Column(
                              children: _autocompleteResults
                                  .map((place) => ListTile(
                                        title: Text(place["description"]),
                                        onTap: () {
                                          locationController.text =
                                              place["description"];
                                          _convertPlaceIdToCoordinates(
                                              place["place_id"]);
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: ElevatedButton(
                      onPressed:_saveTripToFirebase,
                      child: Text('Add Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B5739), // Button color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Border radius
                         minimumSize: Size(300, 60),
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold text
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
