import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Add this import

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

  // Function to fetch current location of the user
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Update camera position to the user's current location
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 9), // Decreased zoom level
    );

    // Add a marker at the current location
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  // Function to handle map creation
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Page"),
        backgroundColor: Color(0xFF0B5739),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 15), // Decreased zoom level
            markers: _markers, // Display markers on the map
          ),
          Positioned(
            left: 16,
            top: 650, // Adjust this value as needed
            child: FloatingActionButton(
              onPressed: _getCurrentLocation, // Get current location when the button is pressed
              backgroundColor: Color.fromARGB(255, 194, 230, 216),
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}



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