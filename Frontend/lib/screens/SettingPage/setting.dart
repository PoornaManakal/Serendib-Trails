import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/BucketListPage.dart';
import 'package:serendib_trails/screens/Create_a_plan.dart';
import 'package:serendib_trails/screens/Explore.dart';
import 'package:serendib_trails/screens/Home.dart';
import 'package:serendib_trails/screens/SettingPage/AboutPage.dart';
import 'package:serendib_trails/screens/SettingPage/AccountPage.dart';
import 'package:serendib_trails/screens/SettingPage/ProfilePage.dart';
import 'package:serendib_trails/screens/SettingPage/SettingsPage.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingScreen(),
    );
  }
}

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _currentIndex = 4; // Index for bottom navigation

  //List of pages for Bottom Navigation
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          "Home",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('lib/assets/images/porfile.jpg'),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      "Amal",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );

                    // Logout function
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            MenuItem(icon: Icons.person, title: "Profile", page: ProfilePage()),
            MenuItem(
                icon: Icons.security,
                title: "Account",
                page: ResetPasswordPage()),
            MenuItem(
                icon: Icons.settings, title: "Settings", page: SettingsPage()),
            MenuItem(icon: Icons.info, title: "About", page: AboutPage()),
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
                            "https://www.instagram.com/accounts/login/?hl=en"),
                        child: Image.asset('lib/assets/images/ing.png',
                            width: 30, height: 30),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _launchURL("https://www.facebook.com"),
                        child: Image.asset('lib/assets/images/facebook.png',
                            width: 30, height: 30),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _launchURL("https://www.linkedin.com"),
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
              icon: Icon(Icons.compass_calibration_sharp), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: "Account"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_added_sharp), label: "About"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

//   void _launchURL(String url) async {
//       final Uri uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//  } else {
//         throw 'Could not launch $url';
//       }
//   }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;

  MenuItem({required this.icon, required this.title, required this.page});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
