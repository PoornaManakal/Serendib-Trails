import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white70,
      selectedItemColor: Color(0xFF0B5739),
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.hotel, size: 30), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 30), label: "Add"),
        BottomNavigationBarItem(icon: Icon(Icons.directions_bus, size: 30), label: "Bookmarks"),
        BottomNavigationBarItem(icon: Icon(Icons.settings, size: 30), label: "Settings"),
      ],
    );
  }
}