import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serendib_trails/screens/Attractions/details.dart';
import 'package:serendib_trails/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen>
    with SingleTickerProviderStateMixin {
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

  void _openInGoogleMaps(
      BuildContext context, String placeName, String placeId) async {
    String encodedPlaceName = Uri.encodeComponent(placeName);
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedPlaceName&query_place_id=$placeId";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
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
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color(0xFFFEF7FF), // Background color of the TabBar
              child: TabBar(
                controller: _tabController,
                isScrollable: true, // Enable scrolling for the TabBar
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
            AttractionsTab(openInGoogleMaps: _openInGoogleMaps),
            AccommodationsTab(openInGoogleMaps: _openInGoogleMaps),
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
                                color: Colors
                                    .grey), // If no image available, display a grey container
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
                                _removeFavoriteTrip(context, tripId);
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
                                    builder: (context) =>
                                        TripDetailScreen(trip: trip),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B5739),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 8),
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

  Future<void> _removeFavoriteTrip(BuildContext context, String tripId) async {
    await FirebaseFirestore.instance
        .collection('favourite_trips')
        .doc(tripId)
        .delete();
  }
}

class AttractionsTab extends StatelessWidget {
  final void Function(BuildContext, String, String) openInGoogleMaps;

  AttractionsTab({required this.openInGoogleMaps});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("Please log in to see your favorite places."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favourite_places')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No favourite places found"));
        }
        final places = snapshot.data!.docs;
        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index].data() as Map<String, dynamic>;
            final placeId = places[index].id;
            final photoUrl = place['photoUrl'] as String?;
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
                                color: Colors
                                    .grey), // If no image available, display a grey container
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
                                _removeFavoritePlace(context, placeId);
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
                            place['name'] ?? "No name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            place['vicinity'] ?? "No address",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                "Rating: ",
                                style: TextStyle(fontSize: 14),
                              ),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(
                                " ${place['rating']?.toString() ?? 'N/A'}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                openInGoogleMaps(
                                    context, place['name'], place['placeId']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B5739),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('View in Maps'),
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

  Future<void> _removeFavoritePlace(
      BuildContext context, String placeId) async {
    await FirebaseFirestore.instance
        .collection('favourite_places')
        .doc(placeId)
        .delete();
  }
}

class AccommodationsTab extends StatelessWidget {
  final void Function(BuildContext, String, String) openInGoogleMaps;

  AccommodationsTab({required this.openInGoogleMaps});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
          child: Text("Please log in to see your favorite accommodations."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favourite_accommodations')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No favourite accommodations found"));
        }
        final accommodations = snapshot.data!.docs;
        return ListView.builder(
          itemCount: accommodations.length,
          itemBuilder: (context, index) {
            final accommodation =
                accommodations[index].data() as Map<String, dynamic>;
            final accommodationId = accommodations[index].id;
            final photoUrl = accommodation['photoUrl'] as String?;
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
                                color: Colors
                                    .grey), // If no image available, display a grey container
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
                                _removeFavoriteAccommodation(
                                    context, accommodationId);
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
                            accommodation['name'] ?? "No name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            accommodation['vicinity'] ?? "No address",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                "Rating: ",
                                style: TextStyle(fontSize: 14),
                              ),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(
                                " ${accommodation['rating']?.toString() ?? 'N/A'}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                openInGoogleMaps(context, accommodation['name'],
                                    accommodation['placeId']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B5739),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('View in Maps'),
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

  Future<void> _removeFavoriteAccommodation(
      BuildContext context, String accommodationId) async {
    await FirebaseFirestore.instance
        .collection('favourite_accommodations')
        .doc(accommodationId)
        .delete();
  }
}

class TransportationTab extends StatelessWidget {
  final void Function(BuildContext, String, String) openInGoogleMaps;

  TransportationTab({required this.openInGoogleMaps});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
          child: Text("Please log in to see your favorite transportations."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favourite_transportations')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No favourite transportations found"));
        }
        final transportations = snapshot.data!.docs;
        return ListView.builder(
          itemCount: transportations.length,
          itemBuilder: (context, index) {
            final transportation =
                transportations[index].data() as Map<String, dynamic>;
            final transportationId = transportations[index].id;
            final photoUrl = transportation['photoUrl'] as String?;
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
                                color: Colors
                                    .grey), // If no image available, display a grey container
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
                                _removeFavoriteTransportation(
                                    context, transportationId);
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
                            transportation['name'] ?? "No name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            transportation['vicinity'] ?? "No address",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                "Rating: ",
                                style: TextStyle(fontSize: 14),
                              ),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(
                                " ${transportation['rating']?.toString() ?? 'N/A'}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                openInGoogleMaps(
                                    context,
                                    transportation['name'],
                                    transportation['placeId']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B5739),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('View in Maps'),
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

  Future<void> _removeFavoriteTransportation(
      BuildContext context, String transportationId) async {
    await FirebaseFirestore.instance
        .collection('favourite_transportations')
        .doc(transportationId)
        .delete();
  }
}
