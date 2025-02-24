import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';
import 'package:serendib_trails/screens/SettingPage/ProfilePage.dart';
import 'package:serendib_trails/screens/SettingPage/setting.dart';
import 'package:serendib_trails/screens/map/map_page.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final User? user = FirebaseAuth.instance.currentUser;
  String userName = "User";
  String userEmail = "Loading...";
  String profilePicUrl = "";


  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          userName = snapshot.data()?['name'] ?? 'User';
          userEmail = snapshot.data()?['email'] ?? 'No Email';
           profilePicUrl = snapshot.data()?['profilePic'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // Background color
        child: Column(
          children: [
            // User Info Section with Full-Width Background
            Container(
              width: double.infinity, // Ensures full width
              color: Color(0xFF0B5739), // Header background color
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  child:CircleAvatar(
                    radius: 40, // Avatar size
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : AssetImage('lib/assets/images/default_profile.jpg') as ImageProvider,
                  ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Navigation Items
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: Color(0xFF0B5739)),
                    title: Text("Home", style: TextStyle(color: Color(0xFF0B5739))),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.bookmark, color: Color(0xFF0B5739)),
                    title: Text("Favourites", style: TextStyle(color: Color(0xFF0B5739))),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.map, color: Color(0xFF0B5739)),
                    title: Text("Map", style: TextStyle(color: Color(0xFF0B5739))),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Color(0xFF0B5739)),
                    title: Text("Settings", style: TextStyle(color: Color(0xFF0B5739))),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder:  (context) => SettingScreen()));
                    },
                  ),
                  Divider(color: Colors.black12),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text("Logout", style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
