import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serendib_trails/screens/Login_Screens/SignIn_screen.dart';
import 'package:serendib_trails/screens/Attractions/details.dart';
import 'package:serendib_trails/widgets/side_menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String userName = "User"; // Default value
  User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _tabController = TabController(length: 3, vsync: this);
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16), // Rounded corners for the dialog
              ),
              titlePadding: EdgeInsets.all(20), // Padding for title
              title: Center(
                child: Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              contentPadding: EdgeInsets.zero, // Remove extra spacing
              actionsPadding: EdgeInsets.zero, // Align buttons to edges
              actions: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16)), // Rounded bottom
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.grey.shade400, // Gray button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft:
                                    Radius.circular(16), // Rounded left corner
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5), // Button height
                            child: Text('No',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF0B5739),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight:
                                    Radius.circular(16), // Rounded right corner
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5), // Button height
                            child: Text('Yes',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
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
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Welcome, $userName!",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)), // Display user's name
          backgroundColor: const Color(0xFF0B5739), // Green color
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Sign out the user
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SigninScreen()));
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color(0xFFFEF7FF), // Background color of the TabBar
              child: TabBar(
                controller: _tabController,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      width: 4.0,
                      color: Color(
                          0xFF0B5739)), // Customize the underline color and thickness
                  insets: EdgeInsets.symmetric(
                      horizontal:
                          16.0), // Customize the horizontal padding of the underline
                ),
                labelColor:
                    Color(0xFF0B5739), // Color of the selected tab label
                unselectedLabelColor:
                    Colors.grey, // Color of the unselected tab label
                tabs: [
                  Tab(text: "Ongoing Trips"),
                  Tab(text: "Upcoming Trips"),
                  Tab(text: "Past Trips"),
                ],
              ),
            ),
          ),
        ),
        drawer: SideMenu(),
        body: TabBarView(
          controller: _tabController,
          children: [
            TripsList(user: user, tripType: 'ongoing'),
            TripsList(user: user, tripType: 'upcoming'),
            TripsList(user: user, tripType: 'completed'),
          ],
        ),
      ),
    );
  }
}

class TripsList extends StatelessWidget {
  final User? user;
  final String tripType;

  const TripsList({required this.user, required this.tripType});

  Future<void> _updateTripType(String tripId, String newTripType) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'tripType': newTripType,
    });
  }

  Future<void> _deleteTrip(String tripId) async {
    await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();
  }

  Future<void> _saveFavoriteTrip(
      BuildContext context, Map<String, dynamic> trip, String tripId) async {
    if (user != null) {
      final userId = user!.uid;

      // Check if the trip already exists in the favourite_trips collection for the current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('favourite_trips')
          .where('userId', isEqualTo: userId)
          .where('tripId', isEqualTo: tripId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Trip does not exist, add it to the collection
        trip['userId'] = userId;
        trip['tripId'] = tripId; // Add tripId to the trip data
        await FirebaseFirestore.instance
            .collection('favourite_trips')
            .add(trip);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Trip added to favourites'),
              backgroundColor: Colors.green),
        );
      } else {
        // Trip already exists, show a message or handle accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Trip already added to favourites'),
              backgroundColor: Colors.orange),
        );
        print('Trip already added to favourites');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          // Text(
          //   'Saved Trips',
          //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          // ),
          Expanded(
            child: user == null
                ? Center(child: Text('User not logged in.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('trips')
                        .where('userId', isEqualTo: user!.uid)
                        .where('tripType', isEqualTo: tripType)
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
                          final trip =
                              trips[index].data() as Map<String, dynamic>;
                          final tripId = trips[index].id;
                          final photoUrl = trip['photoUrl'] as String?;
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            elevation: 5,
                            child: GestureDetector(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      // Display the image (if available)
                                      photoUrl != null
                                          ? Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              height: 180,
                                              width: double.infinity,
                                            )
                                          : Container(
                                              height: 180,
                                              color: Colors
                                                  .grey), // If no image available, display a grey container
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.bookmark_border,
                                                color: Colors.black),
                                            onPressed: () {
                                              // Handle bookmark action
                                              _saveFavoriteTrip(
                                                  context, trip, tripId);
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.delete_outline,
                                                color: Colors.black),
                                            onPressed: () {
                                              _deleteTrip(tripId);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trip['cityName'] ?? "No name",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Interests: ${trip['selectedInterests']?.join(', ') ?? 'No interests available'}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 5),
                                        if (tripType == 'upcoming')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TripDetailScreen(
                                                              trip: trip),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF0B5739),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text('View Details'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _updateTripType(
                                                      tripId, 'ongoing');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF0B5739),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text('Start Trip'),
                                              ),
                                            ],
                                          ),
                                        if (tripType == 'ongoing')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TripDetailScreen(
                                                              trip: trip),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF0B5739),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text('View Details'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _updateTripType(
                                                      tripId, 'completed');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF0B5739),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text('Complete Trip'),
                                              ),
                                            ],
                                          ),
                                        if (tripType == 'completed')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TripDetailScreen(
                                                              trip: trip),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF0B5739),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 50,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text('View Details'),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// bookmark section should be implemented
