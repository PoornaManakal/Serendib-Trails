// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// Future <void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load();
//   runApp(AccommodationFinderApp());
// }

// class AccommodationFinderApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Accommodation Finder',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: AccommodationScreen(),
//     );
//   }
// }

// class AccommodationScreen extends StatefulWidget {
//   @override
//   _AccommodationScreenState createState() => _AccommodationScreenState();
// }

// class _AccommodationScreenState extends State<AccommodationScreen> {
//   String selectedType = "Hotel";
//   String selectedBudget = "Any";
//   List<Map<String, dynamic>> accommodations = [];

//   final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

//   Future<void> fetchAccommodations() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
    
//     String url =
//         "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
//         "location=${position.latitude},${position.longitude}"
//         "&radius=5000"
//         "&type=lodging"
//         "&keyword=$selectedType"
//         "&key=$apiKey";

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       setState(() {
//         accommodations = List<Map<String, dynamic>>.from(
//             json.decode(response.body)['results']);
//       });
//     } else {
//       throw Exception("Failed to load accommodations");
//     }
//   }

//   void openGoogleMaps(double lat, double lng) async {
//     final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw "Could not launch $url";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Accommodation Finder')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 DropdownButton<String>(
//                   value: selectedType,
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedType = newValue!;
//                     });
//                   },
//                   items: <String>['Hotel', 'Hostel', 'Guesthouse', 'Resort']
//                       .map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                 ),
//                 DropdownButton<String>(
//                   value: selectedBudget,
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedBudget = newValue!;
//                     });
//                   },
//                   items: <String>['Any', 'Low', 'Medium', 'Luxury']
//                       .map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                 ),
//                 ElevatedButton(
//                   onPressed: fetchAccommodations,
//                   child: Text("Find Accommodations"),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: accommodations.length,
//               itemBuilder: (context, index) {
//                 final place = accommodations[index];
//                 final name = place['name'];
//                 final rating = place['rating']?.toString() ?? 'No Rating';
//                 final lat = place['geometry']['location']['lat'];
//                 final lng = place['geometry']['location']['lng'];

//                 return Card(
//                   margin: EdgeInsets.all(8),
//                   child: ListTile(
//                     leading: Icon(Icons.hotel, color: Colors.blue),
//                     title: Text(name),
//                     subtitle: Text("Rating: $rating"),
//                     trailing: IconButton(
//                       icon: Icon(Icons.map, color: Colors.green),
//                       onPressed: () => openGoogleMaps(lat, lng),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
