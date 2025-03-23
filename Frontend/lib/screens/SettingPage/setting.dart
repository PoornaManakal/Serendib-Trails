import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';
import 'package:serendib_trails/screens/SettingPage/AboutPage.dart';
import 'package:serendib_trails/screens/SettingPage/UpdatePassword.dart';
import 'package:serendib_trails/screens/SettingPage/ProfilePage.dart';
import 'package:serendib_trails/screens/SettingPage/SettingsPage.dart';
import 'package:serendib_trails/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  User? user;
  String userName = "";
  String userEmail = "";
  String profilePicUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc["name"] ?? "";
          userEmail = userDoc["email"] ?? "";
          profilePicUrl = userDoc["profilePic"] ?? "";
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0B5739),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            },
          ),
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: profilePicUrl.isNotEmpty
                          ? NetworkImage(profilePicUrl)
                          : AssetImage('lib/assets/images/default_profile.jpg')
                              as ImageProvider,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            titlePadding: EdgeInsets.all(20),
                            title: Center(
                              child: Text(
                                'Are you sure you want to sign out?',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            actionsPadding: EdgeInsets.zero,
                            actions: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(16)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Colors.grey.shade400,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(16),
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text('No',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                          FirebaseAuth.instance.signOut();
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SigninScreen()),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xFF0B5739),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(16),
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text('Yes',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              MenuItem(
                icon: Icons.person,
                title: "Profile",
                page: ProfilePage(),
                iconColor: Color(0xFF0B5739),
                textColor: Color(0xFF0B5739),
              ),
              MenuItem(
                icon: Icons.security,
                title: "Account",
                page: UpdatePasswordPage(),
                iconColor: Color(0xFF0B5739),
                textColor: Color(0xFF0B5739),
              ),
              MenuItem(
                icon: Icons.settings,
                title: "Settings",
                page: SettingsPage(),
                iconColor: Color(0xFF0B5739),
                textColor: Color(0xFF0B5739),
              ),
              MenuItem(
                icon: Icons.info,
                title: "About",
                page: AboutPage(),
                iconColor: Color(0xFF0B5739),
                textColor: Color(0xFF0B5739),
              ),
              Spacer(),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Designed & Developed by\nTeam Serendib Trails",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("Catch us on"),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _launchURL(
                              "https://www.instagram.com/serendibtrailsofficial?igsh=M2NrbnY5a2toMGFo"),
                          child: Image.asset('lib/assets/images/ing.png',
                              width: 30, height: 30),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _launchURL(
                              "https://www.facebook.com/share/162tHP81Ey/"),
                          child: Image.asset('lib/assets/images/facebook.png',
                              width: 30, height: 30),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _launchURL(
                              "https://www.linkedin.com/company/serenedib-trails-lk"),
                          child: Image.asset('lib/assets/images/link.png',
                              width: 30, height: 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;
  final Color iconColor;
  final Color textColor;

  MenuItem({
    required this.icon,
    required this.title,
    required this.page,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}