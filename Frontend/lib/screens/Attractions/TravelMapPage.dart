//show selected places
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong; // Alias for latlong2 LatLng
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class TravelMapPage extends StatefulWidget {
  final Map<String, List<dynamic>> suggestedPlaces; // Accept suggested places as a parameter

  TravelMapPage({required this.suggestedPlaces});

  @override
  _TravelMapPageState createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {}; // To store the markers
  late Position _currentPosition;

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });

    // Move the camera to the current location
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 13),
    );

    // Call the function to add markers based on current search (suggested places)
    _addMarkers();
  }

  // Function to add markers to the map based on suggested places
  void _addMarkers() {
    _markers.clear();

    // Loop through the suggested places from current search (selected interests)
    widget.suggestedPlaces.forEach((category, placesList) {
      for (var place in placesList) {
        double lat = place['geometry']['location']['lat'];
        double lng = place['geometry']['location']['lng'];

        _markers.add(
          Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['vicinity'],
            ),
          ),
        );
      }
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get current location when the screen starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Map"),
        backgroundColor: Color(0xFF0B5739),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition:
            CameraPosition(target: LatLng(6.9271, 79.8612), zoom: 13), // Initial camera position
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}



