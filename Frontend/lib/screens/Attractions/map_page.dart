import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _pGooglePlex = LatLng(7.8731, 80.7718); // Default to Sri Lanka's center
  late GoogleMapController _mapController;

  // Markers to display on the map
  final Set<Marker> _markers = {};
  late Position _currentPosition;
  List<dynamic> _autocompleteResults = [];

  // Fetch the Google API Key from the .env file
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

  // Function to fetch current location of the user
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    setState(() {
      _currentPosition = position;
    });

    // Update camera position to the user's current location
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 15), 
    );

    // Add a marker at the current location
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), 
        ),
      );
    });
  }

  // Function to handle map creation
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _getCurrentLocation(); // Fetch current location after map is created
  }

  // Function to fetch autocomplete suggestions for places (Limited to Sri Lanka)
  Future<void> _fetchAutocompleteSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _autocompleteResults = [];
      });
      return;
    }

    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&components=country:LK&key=$apiKey"; // Restricting to Sri Lanka (country:LK)

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _autocompleteResults = data['predictions'];
      });
    }
  }

  // Function to handle place selection from suggestions or search box
  Future<void> _handlePlaceSelection(String placeId) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final place = data['result'];
      final location = place['geometry']['location'];

      LatLng placeLatLng = LatLng(location['lat'], location['lng']);

      // Clear previous markers and add a red marker for the selected place
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId(place['place_id']),
            position: placeLatLng,
            infoWindow: InfoWindow(title: place['name']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Red marker for selected place
          ),
        );

        // Move camera to the selected place
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(placeLatLng, 15),
        );

        // Clear the autocomplete results (hide suggestion list)
        _autocompleteResults = [];
      });
    }
  }

  // Function to handle search when "Search" is pressed
  void _onSearch(String searchText) {
    // Simulate user selecting from search bar
    if (_autocompleteResults.isNotEmpty) {
      final placeId = _autocompleteResults[0]['place_id']; // Get first suggestion place_id
      _handlePlaceSelection(placeId); // Call the function to add the place to the map
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Map", // Title text as "Map"
          style: TextStyle(color: Colors.white), 
        ),
        backgroundColor: Color(0xFF0B5739),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 15), // Adjusted zoom level
            markers: _markers, // Display markers on the map
          ),
          Positioned(
            top: 25, // Adjust this value to position the search box properly
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: TextField(
                onChanged: _fetchAutocompleteSuggestions,
                onSubmitted: _onSearch,
                decoration: InputDecoration(
                  hintText: "Search for places in Sri Lanka",
                  suffixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,

            top: 650, // Adjust this value as needed

            bottom: 16, // Positioned at the bottom for current location button

            child: FloatingActionButton(
              onPressed: _getCurrentLocation, // Get current location when the button is pressed
              backgroundColor: Color.fromARGB(255, 194, 230, 216),
              child: Icon(Icons.my_location),
            ),
          ),
          // Autocomplete suggestions
          if (_autocompleteResults.isNotEmpty)
            Positioned(
              top: 85, // Adjust the position to make space for the search box
              left: 16,
              right: 16,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: _autocompleteResults
                      .map((place) => ListTile(
                            title: Text(place['description']),
                            onTap: () {
                              _handlePlaceSelection(place['place_id']);
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart'; 

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   static const _pGooglePlex = LatLng(7.8731, 80.7718); // Default to Sri Lanka's center
//   late GoogleMapController _mapController;

//   // Markers to display on the map
//   final Set<Marker> _markers = {};

//   // Function to fetch current location of the user
//   Future<void> _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     // Update camera position to the user's current location
//     _mapController.animateCamera(
//       CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 9), // Decreased zoom level
//     );

//     // Add a marker at the current location
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: MarkerId('current_location'),
//           position: LatLng(position.latitude, position.longitude),
//           infoWindow: InfoWindow(title: 'Your Location'),
//         ),
//       );
//     });
//   }

//   // Function to handle map creation
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Map Page"),
//         backgroundColor: Color(0xFF0B5739),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 15), // Decreased zoom level
//             markers: _markers, // Display markers on the map
//           ),
//           Positioned(
//             left: 16,
//             top: 720, // Adjust this value as needed
//             child: FloatingActionButton(
//               onPressed: _getCurrentLocation, // Get current location when the button is pressed
//               backgroundColor: Color.fromARGB(255, 194, 230, 216),
//               child: Icon(Icons.my_location),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';


// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   static const _pGooglePlex = LatLng(7.8731, 80.7718);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: GoogleMap(initialCameraPosition:CameraPosition(target: _pGooglePlex,zoom: 13)));
//   }
//  }

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   static const _pGooglePlex = LatLng(7.8731, 80.7718);

//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       // Handle navigation based on the selected index
//       // For example, you can use Navigator.pushReplacement to navigate to other pages
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Map Page"),
//         backgroundColor: Color(0xFF0B5739),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 13),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.explore),
//             label: 'Explore',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.map),
//             label: 'Map',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bookmark),
//             label: 'Bookmarks',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//         selectedItemColor: Color(0xFF0B5739),
//         unselectedItemColor: Colors.black,
//       ),
//     );
//   }
// }