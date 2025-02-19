import 'package:flutter/material.dart';
//import 'package:first_project/AccountPage.dart';
import 'package:serendib_trails/screens/BucketListPage.dart';
import 'package:serendib_trails/screens/Create_a_plan.dart';
import 'package:serendib_trails/screens/Explore.dart';
import 'package:serendib_trails/screens/Home.dart';
import 'package:serendib_trails/screens/SettingPage/SendFeedback.dart';
import 'package:serendib_trails/screens/SettingPage/setting.dart';

//import 'package:first_project/LanguageSettingsPage.dart'; // Example page
//import 'package:first_project/NotificationSettingsPage.dart'; // Example page
//import 'package:first_project/UpdateVersionPage.dart'; // Example page

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _currentIndex = 4; // Initial index for the BottomNavigationBar

  // List of pages for Bottom Navigation
  final List<Widget> _pages = [
    HomeScreen(),
    ExplorePage(),
    CreateAPlanPage(),
    BucketListPage(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text("App language"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the App Language settings page
              //Navigator.push(
              //context,
              //MaterialPageRoute(builder: (context) => LanguageSettingsPage()),
              //);
            },
          ),
          ListTile(
            title: Text("Notification"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the Notification settings page
              //Navigator.push(
              //context,
              // MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
              // );
            },
          ),
          ListTile(
            title: Text("Update version"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the Update Version page
              // Navigator.push(
              // context,
              //  MaterialPageRoute(builder: (context) => UpdateVersionPage()),
              //);
            },
          ),
          ListTile(
            title: Text("Send Feedback"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              //Navigate to the Update Version page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SendFeedbackPage()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _pages[index]),
            );
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.navigate_next_rounded), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: "Account"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "About"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
