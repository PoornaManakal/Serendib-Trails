import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF0B5739),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 0 ? Icons.home : Icons.home_outlined,
            size: 30,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 1 ? Icons.hotel : Icons.local_hotel_outlined,
            size: 30,
          ),
          label: "Accommodations",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2 ? Icons.add_circle : Icons.add_circle_outline,
            size: 30,
          ),
          label: "Create Trip",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 3
                ? Icons.directions_bus
                : Icons.directions_bus_outlined,
            size: 30,
          ),
          label: "Transportations",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 4 ? Icons.settings : Icons.settings_outlined,
            size: 30,
          ),
          label: "Settings",
        ),
      ],
    );
  }
}