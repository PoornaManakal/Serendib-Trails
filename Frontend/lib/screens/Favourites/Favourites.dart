// filepath: /Users/chamodpankaja/Documents/IIT/L5/SDGP/Serendib-Trails/Frontend/lib/screens/Favourites/Favourites.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serendib_trails/screens/Attractions/details.dart';
import 'package:serendib_trails/screens/main_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0B5739),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          title: Text("Favourites",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color(0xFFFEF7FF), // Background color of the TabBar
              child: TabBar(
                controller: _tabController,
                isScrollable: true, // Enable scrolling for the TabBar
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4.0, color: Color(0xFF0B5739)), // Customize the underline color and thickness
                  insets: EdgeInsets.symmetric(horizontal: 16.0), // Customize the horizontal padding of the underline
                ),
                labelColor: Color(0xFF0B5739), // Color of the selected tab label
                unselectedLabelColor: Colors.grey, // Color of the unselected tab label
                tabs: [
                  Tab(text: "Trips"),
                  Tab(text: "Attractions"),
                  Tab(text: "Accommodations"),
                  Tab(text: "Transportations"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            TripsTab(),
            Center(child: Text("Attractions Content Here")),
            Center(child: Text("Accommodations Content Here")),
            Center(child: Text("Transportations Content Here")),
          ],
        ),
      ),
    );
  }
}

class TripsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("Please log in to see your favorite trips."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favourite_trips')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No favourite trips found"));
        }
        final trips = snapshot.data!.docs;
        return ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index].data() as Map<String, dynamic>;
            final tripId = trips[index].id;
            final photoUrl = trip['photoUrl'] as String?;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                                color: Colors.grey), // If no image available, display a grey container
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.bookmark, color: Colors.black),
                              onPressed: () {
                                // Handle bookmark action
                                _removeFavoriteTrip(tripId);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripDetailScreen(trip: trip),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B5739),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('View Details'),
                            ),
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
    );
  }

  Future<void> _removeFavoriteTrip(String tripId) async {
    await FirebaseFirestore.instance.collection('favourite_trips').doc(tripId).delete();
  }
}