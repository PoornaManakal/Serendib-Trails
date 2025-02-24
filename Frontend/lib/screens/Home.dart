import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/BucketListPage.dart';
import 'package:serendib_trails/screens/Create_a_plan.dart';
import 'package:serendib_trails/screens/Explore.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';
import 'package:serendib_trails/screens/SettingPage/setting.dart';
import 'package:serendib_trails/screens/map/details.dart';
import 'package:serendib_trails/screens/map/map_page.dart';
import 'package:serendib_trails/screens/map/select_interests_screen.dart';
import 'package:serendib_trails/widgets/nav_bar.dart';
import 'package:serendib_trails/widgets/side_menu.dart';
import 'package:serendib_trails/screens/Home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "User"; // Default value
  User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
  int _currentIndex = 0; // Default to Home page

  final List<Widget> _pages = [
    HomeScreen(),
    ExplorePage(),
    SelectInterestsScreen(),
    BucketListPage(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      // Query Firestore using the UID
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        String fullName = snapshot['name'];
        List<String> nameParts = fullName.split(' ');
        String firstName = nameParts.first;
        setState(() {
          userName = firstName;
        });
      }
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName!"), // Display user's name
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the user
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SigninScreen()));
            },
          ),
        ],
      ),
      drawer: SideMenu(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hello, $userName!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Click me"),
              onPressed: () {
                // Add button press logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelectInterestsScreen()),
                );
              },
            ),
            ElevatedButton(
              child: Text("Map"),
              onPressed: () {
                // Add button press logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text("Logout"),
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Sign out the user
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SigninScreen()));
              },
            ),
            SizedBox(height: 20),
            Text(
              'Saved Trips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: user == null
                  ? Center(child: Text('User not logged in.'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('trips')
                          .where('userId', isEqualTo: user!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No trips found.'));
                        }
                        final trips = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final trip = trips[index].data() as Map<String, dynamic>;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              elevation: 5,
                              child: ListTile(
                                title: Text('Trip ${index + 1}'),
                                subtitle: Text('Interests: ${trip['selectedInterests']?.join(', ') ?? 'No interests available'}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TripDetailScreen(trip: trip),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}