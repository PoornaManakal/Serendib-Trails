// //with small pic
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:serendib_trails/screens/main_screen.dart';
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class AccommodationFinderApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Accommodation Finder',
//       home: AccommodationScreen(),
//     );
//   }
// }

// class AccommodationScreen extends StatefulWidget {
//   @override
//   _AccommodationScreenState createState() => _AccommodationScreenState();
// }

// class _AccommodationScreenState extends State<AccommodationScreen> {
//   Position? _currentPosition;
//   String selectedType = "Hotel";
//   String? selectedLocation;
//   List<Map<String, dynamic>> accommodations = [];
//   List<dynamic> _autocompleteResults = [];
//   bool isLoading = false;
//   TextEditingController locationController = TextEditingController();

//   final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentPosition();
//   }

//   Future<void> _getCurrentPosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     _currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {});
//   }

//   Future<void> _fetchAutocompleteSuggestions(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         _autocompleteResults = [];
//       });
//       return;
//     }

//     String url =
//         "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&components=country:LK&key=$apiKey";

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         _autocompleteResults = data["predictions"];
//       });
//     }
//   }

//   Future<void> _fetchAccommodations() async {
//     setState(() {
//       isLoading = true;
//     });

//     double? latitude;
//     double? longitude;

//     if (selectedLocation != null) {
//       String url =
//           "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(selectedLocation!)}&key=$apiKey";
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data["results"].isNotEmpty) {
//           latitude = data["results"][0]["geometry"]["location"]["lat"];
//           longitude = data["results"][0]["geometry"]["location"]["lng"];
//         }
//       }
//     } else if (_currentPosition != null) {
//       latitude = _currentPosition!.latitude;
//       longitude = _currentPosition!.longitude;
//     }

//     if (latitude == null || longitude == null) {
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     String url =
//         "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
//         "location=$latitude,$longitude"
//         "&radius=10000"
//         "&type=lodging"
//         "&keyword=$selectedType"
//         "&key=$apiKey";

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
//           json.decode(response.body)['results']);

//       setState(() {
//         accommodations = results.take(7).toList(); // Limit results to 7
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception("Failed to load accommodations");
//     }
//   }

//   void _openInGoogleMaps(String placeName, String placeId) async {
//     String encodedPlaceName = Uri.encodeComponent(placeName);
//     String googleMapsUrl =
//         "https://www.google.com/maps/search/?api=1&query=$encodedPlaceName&query_place_id=$placeId";

//     if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
//       await launchUrl(Uri.parse(googleMapsUrl));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not open Google Maps.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => MainScreen()),
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color(0xFF0B5739),
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => MainScreen()),
//               );
//             },
//           ),
//           title: Text("Accommodation Finder",
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white)),
//           centerTitle: false,
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   // Location Search Bar
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: locationController,
//                           decoration: InputDecoration(
//                             hintText: "Enter Location",
//                             border: OutlineInputBorder(),
//                             suffixIcon: Icon(Icons.search),
//                           ),
//                           onChanged: _fetchAutocompleteSuggestions,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.my_location, color: Color(0xFF0B5739)),
//                         onPressed: () {
//                           locationController.clear();
//                           setState(() {
//                             selectedLocation = null;
//                           });
//                           _fetchAccommodations();
//                         },
//                       ),
//                     ],
//                   ),
//                   if (_autocompleteResults.isNotEmpty)
//                     Container(
//                       color: Colors.white,
//                       child: Column(
//                         children: _autocompleteResults
//                             .map((place) => ListTile(
//                                   title: Text(place["description"]),
//                                   onTap: () {
//                                     setState(() {
//                                       selectedLocation = place["description"];
//                                       locationController.text =
//                                           place["description"];
//                                       _autocompleteResults = [];
//                                     });
//                                     _fetchAccommodations();
//                                   },
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                   SizedBox(height: 10),
//                   // Type Selector & Search Button
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           value: selectedType,
//                           onChanged: (String? newValue) {
//                             setState(() {
//                               selectedType = newValue!;
//                             });
//                           },
//                           items: <String>[
//                             'Hotel',
//                             'Hostel',
//                             'Guesthouse',
//                             'Resort',
//                             'Home Stay'
//                           ].map<DropdownMenuItem<String>>((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: _fetchAccommodations,
//                         child: Icon(Icons.search, color: Colors.white),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF0B5739),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8.0)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : ListView.builder(
//                       itemCount: accommodations.length,
//                       itemBuilder: (context, index) {
//                         final place = accommodations[index];
//                         return Card(
//                           margin: EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 15),
//                           elevation: 5,
//                           child: ListTile(
//                             leading: Image.network(
//                               place["photos"] != null
//                                   ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place["photos"][0]["photo_reference"]}&key=$apiKey"
//                                   : '',
//                               width: 100,
//                               fit: BoxFit.cover,
//                             ),
//                             title: Text(place["name"] ?? "No name"),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:serendib_trails/screens/main_screen.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccommodationFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accommodation Finder',
      home: AccommodationScreen(),
    );
  }
}

class AccommodationScreen extends StatefulWidget {
  @override
  _AccommodationScreenState createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  Position? _currentPosition;
  String selectedType = "Hotel";
  String selectedBudget = "Any";
  List<Map<String, dynamic>> accommodations = [];
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

  Future<void> fetchAccommodations() async {
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

    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "location=${_currentPosition!.latitude},${_currentPosition!.longitude}"
        "&radius=10000"
        "&type=lodging"
        "&keyword=$selectedType"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
          json.decode(response.body)['results']);

      setState(() {
        accommodations = results;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception("Failed to load accommodations");
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
          title: Text("Accommodation Finder",
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
                        items: <String>['Hotel', 'Hostel', 'Guesthouse', 'Resort', 'Home Stay']
                            .map<DropdownMenuItem<String>>((String value) {
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
                    onPressed: fetchAccommodations,
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
                      itemCount: accommodations.length > 5 ? 5 : accommodations.length,
                      itemBuilder: (context, index) {
                        final place = accommodations[index];
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
                            child: Stack(
                              children: [
                                Column(
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
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.bookmark_border,
                                          color: Colors.black),
                                      onPressed: () {
                                        _saveFavoriteAccommodation(context, place);
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
      ),
    );
  }


  Future<void> _saveFavoriteAccommodation(BuildContext context, Map<String, dynamic> place) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final placeId = place['place_id'];

      // Check if the place already exists in the favourite_places collection for the current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('favourite_accommodations')
          .where('userId', isEqualTo: userId)
          .where('placeId', isEqualTo: placeId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Place does not exist, add it to the collection
        await FirebaseFirestore.instance.collection('favourite_accommodations').add({
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
