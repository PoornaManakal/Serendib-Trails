import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/Accomodations/Accomodations.dart';
import 'package:serendib_trails/screens/BucketListPage.dart';
import 'package:serendib_trails/screens/Explore.dart';
import 'package:serendib_trails/screens/Home.dart';
import 'package:serendib_trails/screens/SettingPage/setting.dart';
import 'package:serendib_trails/screens/Attractions/select_interests_screen.dart';
import 'package:serendib_trails/widgets/nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;

  MainScreen({this.selectedIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  final List<Widget> _pages = [
    HomeScreen(),
    AccommodationScreen(),
    SelectInterestsScreen(),
    BucketListPage(),
    SettingScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}