import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:serendib_trails/screens/main_screen.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  bool isLoading = false;

  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

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

  Future<void> fetchTransportations() async {
    setState(() {
      isLoading = true;
    });

    await _getCurrentPosition();
    if (_currentPosition == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    String keyword;
    switch (selectedType) {
      case 'Tuk Tuk Rental':
        keyword = 'tuk tuk rental|tuktuk rental|tuk-tuk rental|three wheeler rental|three wheel rent';
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

    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "location=${_currentPosition!.latitude},${_currentPosition!.longitude}"
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
          centerTitle: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    onPressed: fetchTransportations,
                    child: Icon(Icons.search, color: Color(0xFF0B5739)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      side: BorderSide(color: Color(0xFF0B5739)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF0B5739))))
                  : ListView.builder(
                      itemCount: transportations.length > 5 ? 5 : transportations.length,
                      itemBuilder: (context, index) {
                        final place = transportations[index];
                        final name = place['name'];
                        final rating = place['rating']?.toString() ?? 'No Rating';
                        final lat = place['geometry']['location']['lat'];
                        final lng = place['geometry']['location']['lng'];

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          elevation: 5,
                          child: GestureDetector(
                            onTap: () {
                              String placeId = place["place_id"];
                              String placeName = place["name"];
                              _openInGoogleMaps(placeName, placeId);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display the image (if available)
                                place["photos"] != null && place["photos"].isNotEmpty
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
                                          Icon(Icons.star,
                                              color: Colors.amber, size: 16),
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

