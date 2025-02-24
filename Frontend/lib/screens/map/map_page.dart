import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _pGooglePlex = LatLng(7.8731, 80.7718);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(initialCameraPosition:CameraPosition(target: _pGooglePlex,zoom: 13)));
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