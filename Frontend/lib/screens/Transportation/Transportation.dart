import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:serendib_trails/screens/main_screen.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransportationFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transportation Finder',
      home: TransportationScreen(),
    );
  }
}

class TransportationScreen extends StatefulWidget {
  @override
  _TransportationScreenState createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  Position? _currentPosition;
  String selectedType = "Tuk Tuk Rental";
  List<Map<String, dynamic>> transportations = [];
  List<dynamic> _autocompleteResults = [];
  bool isLoading = false;

  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _getCurrentPositionAndFetchTransportations() async {
    try {
      setState(() {
        isLoading = true;
      });

      await _getCurrentPosition();
      if (_currentPosition != null) {
        fetchTransportations(location: null);
      }
      _locationController.clear();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch current location: $e')),
      );
    }
  }

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

  Future<void> fetchTransportations({String? location}) async {
    setState(() {
      isLoading = true;
    });

    double latitude;
    double longitude;

    if (location != null && location.isNotEmpty) {
      String geocodingUrl =
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(location)}&key=$apiKey";

      final response = await http.get(Uri.parse(geocodingUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          latitude = data['results'][0]['geometry']['location']['lat'];
          longitude = data['results'][0]['geometry']['location']['lng'];
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location not found.')),
          );
          return;
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception("Failed to fetch location coordinates");
      }
    } else {
      await _getCurrentPosition();
      if (_currentPosition == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      latitude = _currentPosition!.latitude;
      longitude = _currentPosition!.longitude;
    }

    String keyword;
    switch (selectedType) {
      case 'Tuk Tuk Rental':
        keyword =
            'tuk tuk rental|tuktuk rental|tuk-tuk rental|three wheeler rental|three wheel rent';
        break;
      case 'Scooter Rental':
        keyword = 'scooter rental';
        break;
      case 'Bike Rental':
        keyword = 'bike rental';
        break;
      case 'Taxi Service':
        keyword = 'taxi service';
        break;
      default:
        keyword = selectedType.toLowerCase();
    }

    String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "location=$latitude,$longitude"
        "&radius=10000"
        "&keyword=$keyword"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
          json.decode(response.body)['results']);

      setState(() {
        transportations = results;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception("Failed to load transportations");
    }
  }

  Future<void> _fetchAutocompleteSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _autocompleteResults = [];
      });
      return;
    }

    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&components=country:LK&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _autocompleteResults = data["predictions"];
      });
    }
  }

  void _selectAutocompleteSuggestion(String description) {
    _locationController.text = description;
    _autocompleteResults = [];
    fetchTransportations(location: description);
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

  Future<void> _saveFavoriteTransportation(
      BuildContext context, Map<String, dynamic> place) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final placeId = place['place_id'];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('favourite_transportations')
          .where('userId', isEqualTo: userId)
          .where('placeId', isEqualTo: placeId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('favourite_transportations')
            .add({
          'userId': userId,
          'placeId': placeId,
          'name': place['name'],
          'vicinity': place['vicinity'],
          'rating': place['rating'],
          'photoUrl': place['photos'] != null && place['photos'].isNotEmpty
              ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=$apiKey"
              : null,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Place added to favourites'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Place already added to favourites'),
              backgroundColor: Colors.orange),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
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
            title: Text("Transportation Finder",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _locationController,
                      focusNode: _focusNode,
                      onChanged: _fetchAutocompleteSuggestions,
                      decoration: InputDecoration(
                        hintText: "Enter a location",
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFF0B5739)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: _focusNode.hasFocus
                                ? Color(0xFF0B5739)
                                : Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Color(0xFF0B5739)),
                        ),
                      ),
                    ),
                    if (_autocompleteResults.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _autocompleteResults.length,
                          itemBuilder: (context, index) {
                            final suggestion = _autocompleteResults[index];
                            return ListTile(
                              title: Text(suggestion["description"]),
                              onTap: () => _selectAutocompleteSuggestion(
                                  suggestion["description"]),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Color(0xFF0B5739)),
                            ),
                            child: DropdownButton<String>(
                              value: selectedType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedType = newValue!;
                                });
                              },
                              items: <String>[
                                'Tuk Tuk Rental',
                                'Scooter Rental',
                                'Bike Rental',
                                'Taxi Service'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              isExpanded: true,
                              underline: SizedBox(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            fetchTransportations(
                                location: _locationController.text);
                          },
                          child: Icon(Icons.search, color: Color(0xFF0B5739)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            side: BorderSide(color: Color(0xFF0B5739)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF0B5739))))
                    : transportations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/images/biker.png', // Path to your image
                                  height: 250, // Adjust the height as needed
                                  width: 250, // Adjust the width as needed
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "No transportations found",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: transportations.length > 10
                                ? 10
                                : transportations.length,
                            itemBuilder: (context, index) {
                              final place = transportations[index];
                              final name = place['name'];
                              final rating =
                                  place['rating']?.toString() ?? 'No Rating';

                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                elevation: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    String placeId = place["place_id"];
                                    String placeName = place["name"];
                                    _openInGoogleMaps(placeName, placeId);
                                  },
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Display the image (if available)
                                          place["photos"] != null &&
                                                  place["photos"].isNotEmpty
                                              ? Image.network(
                                                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place["photos"][0]["photo_reference"]}&key=$apiKey",
                                                  fit: BoxFit.cover,
                                                  height: 180,
                                                  width: double.infinity,
                                                )
                                              : Container(), // If no image available, display nothing
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                      // Bookmark button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.bookmark_border,
                                                color: Colors.black),
                                            onPressed: () {
                                              _saveFavoriteTransportation(
                                                  context, place);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _getCurrentPositionAndFetchTransportations,
            backgroundColor: Colors.white,
            child: Icon(Icons.my_location, color: Color(0xFF0B5739)),
          ),
        ),
      ),
    );
  }
}
