import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;

class TravelMapPage extends StatefulWidget {
  final Map<String, List<dynamic>> suggestedPlaces;

  TravelMapPage({required this.suggestedPlaces});

  @override
  _TravelMapPageState createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isMapInitialized = false;
  LatLng _firstPlace = LatLng(6.9271, 79.8612); // Default (Colombo, Sri Lanka)

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _currentPosition = position;
    });

    // Call function to sort places & add markers
    _sortAndAddMarkers();
  }

  // Function to find the best route (Greedy Nearest Neighbor)
  void _sortAndAddMarkers() async {
    if (_currentPosition == null) return;

    final latlong.Distance distanceCalculator = latlong.Distance();
    List<Map<String, dynamic>> placesList = [];

    widget.suggestedPlaces.forEach((category, places) {
      for (var place in places) {
        double lat = place['geometry']['location']['lat'];
        double lng = place['geometry']['location']['lng'];

        placesList.add({
          'lat': lat,
          'lng': lng,
          'name': place['name'],
          'vicinity': place['vicinity'],
        });
      }
    });

    List<Map<String, dynamic>> sortedPlaces = [];
    latlong.LatLng virtualCurrentLocation =
        latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    while (placesList.isNotEmpty) {
      placesList.sort((a, b) {
        double distA = distanceCalculator.distance(
            virtualCurrentLocation, latlong.LatLng(a['lat'], a['lng']));
        double distB = distanceCalculator.distance(
            virtualCurrentLocation, latlong.LatLng(b['lat'], b['lng']));
        return distA.compareTo(distB);
      });

      var nearestPlace = placesList.removeAt(0);
      sortedPlaces.add(nearestPlace);

      // Move virtual current location to the selected place
      virtualCurrentLocation =
          latlong.LatLng(nearestPlace['lat'], nearestPlace['lng']);
    }

    _markers.clear();
    for (int i = 0; i < sortedPlaces.length; i++) {
      double lat = sortedPlaces[i]['lat'];
      double lng = sortedPlaces[i]['lng'];
      String name = sortedPlaces[i]['name'];
      String vicinity = sortedPlaces[i]['vicinity'];

      BitmapDescriptor markerIcon = await _createNumberedMarker(i + 1);

      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: "$name",
            snippet: "Stop #${i + 1} - $vicinity",
          ),
          icon: markerIcon,
        ),
      );

      // Save the first place to set camera there
      if (i == 0) {
        _firstPlace = LatLng(lat, lng);
      }
    }

    setState(() {});

    // **Move camera to the first place instead of user location**
    if (sortedPlaces.isNotEmpty && !_isMapInitialized) {
      Future.delayed(Duration(milliseconds: 500), () {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_firstPlace, 15),
        );
        _isMapInitialized = true;
      });
    }
  }

  // Function to create numbered markers dynamically (Google Maps-style pin)
  Future<BitmapDescriptor> _createNumberedMarker(int number) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.red;

    const double markerWidth = 100;
    const double markerHeight = 120;

    Path pinPath = Path()
      ..moveTo(markerWidth / 2, markerHeight)
      ..lineTo(0, markerHeight / 3)
      ..quadraticBezierTo(markerWidth / 2, 0, markerWidth, markerHeight / 3)
      ..lineTo(markerWidth / 2, markerHeight)
      ..close();

    canvas.drawPath(pinPath, paint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: number.toString(),
      style: TextStyle(
        fontSize: 40,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset((markerWidth - textPainter.width) / 2,
            (markerHeight / 2 - textPainter.height) / 2));

    final img = await pictureRecorder
        .endRecording()
        .toImage(markerWidth.toInt(), markerHeight.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Travel Map",
          style: TextStyle(
            color: const ui.Color.fromARGB(255, 255, 255, 255), // **Changed text color**
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0B5739),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const ui.Color.fromARGB(255, 255, 255, 255)), // **Changed arrow color**
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _firstPlace, // **Now starts from first place**
          zoom: 15,
        ),
        markers: _markers,
        myLocationEnabled: false, // Don't show current location
        myLocationButtonEnabled: false,
      ),
    );
  }
}





//show selected places
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart' as latlong; // Alias for latlong2 LatLng
// import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

// class TravelMapPage extends StatefulWidget {
//   final Map<String, List<dynamic>> suggestedPlaces; // Accept suggested places as a parameter

//   TravelMapPage({required this.suggestedPlaces});

//   @override
//   _TravelMapPageState createState() => _TravelMapPageState();
// }

// class _TravelMapPageState extends State<TravelMapPage> {
//   late GoogleMapController _mapController;
//   Set<Marker> _markers = {}; // To store the markers
//   late Position _currentPosition;

//   // Function to get current location
//   Future<void> _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       _currentPosition = position;
//     });

//     // Move the camera to the current location
//     _mapController.animateCamera(
//       CameraUpdate.newLatLngZoom(
//         LatLng(position.latitude, position.longitude), 13),
//     );

//     // Call the function to add markers based on current search (suggested places)
//     _addMarkers();
//   }

//   // Function to add markers to the map based on suggested places
//   void _addMarkers() {
//     _markers.clear();

//     // Loop through the suggested places from current search (selected interests)
//     widget.suggestedPlaces.forEach((category, placesList) {
//       for (var place in placesList) {
//         double lat = place['geometry']['location']['lat'];
//         double lng = place['geometry']['location']['lng'];

//         _markers.add(
//           Marker(
//             markerId: MarkerId(place['place_id']),
//             position: LatLng(lat, lng),
//             infoWindow: InfoWindow(
//               title: place['name'],
//               snippet: place['vicinity'],
//             ),
//           ),
//         );
//       }
//     });

//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation(); // Get current location when the screen starts
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Travel Map"),
//         backgroundColor: Color(0xFF0B5739),
//       ),
//       body: GoogleMap(
//         onMapCreated: (controller) {
//           _mapController = controller;
//         },
//         initialCameraPosition:
//             CameraPosition(target: LatLng(6.9271, 79.8612), zoom: 13), // Initial camera position
//         markers: _markers,
//         myLocationEnabled: true,
//         myLocationButtonEnabled: false,
//       ),
//     );
//   }
// }



