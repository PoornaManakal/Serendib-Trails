import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TravelMapPage extends StatefulWidget {
  final Map<String, List<dynamic>> suggestedPlaces;

  TravelMapPage({required this.suggestedPlaces});

  @override
  _TravelMapPageState createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  bool _isMapInitialized = false;
  LatLng _firstPlace = LatLng(6.9271, 79.8612); // Default: Colombo, Sri Lanka
  double _totalDistance = 0.0;
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? ""; 

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get Current Location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _currentPosition = position;
    });

    _sortAndAddMarkers();
  }

  // Fetch Google Directions API Route
  Future<List<LatLng>> _getRouteCoordinates(LatLng start, LatLng end) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'].isEmpty) return [];

      // Extract total distance
      _totalDistance += data['routes'][0]['legs'][0]['distance']['value'] / 1000; // Convert meters to km

      // Extract polyline points
      String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
      return _decodePolyline(encodedPolyline);
    } else {
      return [];
    }
  }

  // Decode Polyline into LatLng Points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    List<int> polylinePoints = encoded.codeUnits;
    int index = 0, lat = 0, lng = 0;

    while (index < polylinePoints.length) {
      int shift = 0, result = 0, byte;
      do {
        byte = polylinePoints[index++] - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = (result & 1) == 1 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = polylinePoints[index++] - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = (result & 1) == 1 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  // Find Best Route & Add Markers
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

    if (placesList.isEmpty) return;

    List<Map<String, dynamic>> sortedPlaces = [];
    latlong.LatLng virtualCurrentLocation =
        latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    _totalDistance = 0.0;
    List<LatLng> routePoints = [LatLng(_currentPosition!.latitude, _currentPosition!.longitude)];

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

      latlong.LatLng newLocation =
          latlong.LatLng(nearestPlace['lat'], nearestPlace['lng']);
      virtualCurrentLocation = newLocation;

      routePoints.add(LatLng(newLocation.latitude, newLocation.longitude));
    }

    _markers.clear();
    _polylines.clear();

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

      if (i == 0) {
        _firstPlace = LatLng(lat, lng);
      }

      // Fetch actual road route
      if (i > 0) {
        List<LatLng> roadRoute =
            await _getRouteCoordinates(routePoints[i - 1], routePoints[i]);

        if (roadRoute.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: PolylineId("route_$i"),
              points: roadRoute,
              color: Color(0xFF0B5739),
              width: 5,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
            ),
          );
        }
      }
    }

    // Final route from last place to final destination
    if (routePoints.length > 1) {
      List<LatLng> finalRoute = await _getRouteCoordinates(
          routePoints[routePoints.length - 2], routePoints.last);

      if (finalRoute.isNotEmpty) {
        _polylines.add(
          Polyline(
            polylineId: PolylineId("final_route"),
            points: finalRoute,
            color: Color(0xFF0B5739),
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );
      }
    }

    setState(() {
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(_firstPlace, 15));
    });
  }

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
        (markerHeight / 2 - textPainter.height) / 2),
  );

  final img = await pictureRecorder
      .endRecording()
      .toImage(markerWidth.toInt(), markerHeight.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Map", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0B5739),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(target: _firstPlace, zoom: 15),
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Text(
                "Total Distance: ${_totalDistance.toStringAsFixed(2)} km",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}