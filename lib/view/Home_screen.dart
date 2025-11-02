import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/view/AnimatedTravelFAB.dart';
import 'package:motto_app/view/Favourites.dart';
import 'package:motto_app/view/card_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:motto_app/view/travel_chatbot_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    saveFcmToken();
    _getCurrentLocation();
  }

  Future<void> saveFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('fcmTokens').doc(token).set(
          {'createdAt': FieldValue.serverTimestamp()},
        );
        log("FCM token saved: $token");
      }
    } catch (e) {
      log("Error saving FCM token: $e");
    }
  }

  String searchQuery = '';

  int selectedTab = 0;
  final List<String> tabItems = [
    'All',
    'Mountains',
    'Beaches',
    'Hill Station',
    'Desert',
    'Devotional',
  ];

  final user = FirebaseAuth.instance.currentUser;
  String currentLocation = "Loading...";
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentLocation = "Location services disabled";
      });
      return;
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentLocation = "Location permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentLocation = "Location permission permanently denied";
      });
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Convert coordinates to human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];
    setState(() {
      currentLocation = "${place.locality}, ${place.administrativeArea}";
      log("Current Location: $currentLocation");
    });
  }

  // Calculate available seats for a trip
  Future<Map<String, dynamic>> _getTripAvailability(
    String tripId,
    int totalCapacity,
  ) async {
    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .collection('bookings')
          .get();

      int bookedSeats = 0;

      for (var booking in bookingsSnapshot.docs) {
        final bookingData = booking.data() as Map<String, dynamic>;
        final bookingStatus = bookingData['status'] ?? 'confirmed';

        if (bookingStatus != 'cancelled') {
          final passengers = bookingData['passengers'] as List<dynamic>? ?? [];

          for (var passenger in passengers) {
            final passengerStatus = passenger['status'] ?? 'confirmed';
            if (passengerStatus != 'cancelled') {
              bookedSeats++;
            }
          }
        }
      }

      int availableSeats = totalCapacity - bookedSeats;
      bool isFullyBooked = availableSeats <= 0;

      return {
        'availableSeats': availableSeats,
        'bookedSeats': bookedSeats,
        'isFullyBooked': isFullyBooked,
      };
    } catch (e) {
      return {
        'availableSeats': totalCapacity,
        'bookedSeats': 0,
        'isFullyBooked': false,
      };
    }
  }

  // Check if a trip is favourite
  Future<bool> _isFavourite(String tripId) async {
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favourites')
        .doc(tripId)
        .get();
    return doc.exists;
  }

  // Toggle Favourite
  Future<void> _toggleFavourite(
    String tripId,
    Map<String, dynamic> tripData,
  ) async {
    if (user == null) return;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favourites')
        .doc(tripId);

    final favDoc = await favRef.get();

    if (favDoc.exists) {
      await favRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Removed from favourites"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      await favRef.set(tripData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added to favourites"),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Top Banner Section
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            expandedHeight: 260,
            elevation: 0,
            stretch: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row
                        Row(
                          children: [
                            const Icon(
                              Icons.pin_drop_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentLocation,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const Favourites(),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.favorite_outline_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return TravelChatbotPage();
                                    },
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SearchBar(
                          hintText: "Search Spots",
                          leading: const Icon(Icons.search),
                          backgroundColor: const WidgetStatePropertyAll(
                            Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase().trim();
                            });
                          },
                        ),

                        const SizedBox(height: 25),
                        Text(
                          "MOVE OUT \nTRAVEL TOGETHER",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Category Tabs

          // Trip Cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No trips available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                final trips = snapshot.data!.docs.where((trip) {
                  final data = trip.data() as Map<String, dynamic>;
                  final destination = (data['destination'] ?? '')
                      .toString()
                      .toLowerCase();
                  final details = (data['details'] ?? '')
                      .toString()
                      .toLowerCase();
                  return destination.contains(searchQuery) ||
                      details.contains(searchQuery);
                }).toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final trip = trips[index];
                    final tripData = trip.data() as Map<String, dynamic>;
                    final tripId = trip.id;
                    final totalCapacity = tripData['groupSize'] ?? 0;

                    final photos =
                        (tripData['photoPaths'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [];
                    final firstPhoto = photos.isNotEmpty ? photos[0] : '';

                    return FutureBuilder<Map<String, dynamic>>(
                      future:
                          Future.wait([
                            _isFavourite(tripId),
                            _getTripAvailability(tripId, totalCapacity),
                          ]).then(
                            (results) => {
                              'isFav': results[0],
                              'availability': results[1],
                            },
                          ),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data?['isFav'] ?? false;
                        final availability =
                            snapshot.data?['availability'] ?? {};
                        final isFullyBooked =
                            availability['isFullyBooked'] ?? false;
                        final availableSeats =
                            availability['availableSeats'] ?? totalCapacity;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CardScreen(
                                  tripData: {'id': tripId, ...tripData},
                                  tripId: tripId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Stack(
                                    children: [
                                      firstPhoto.isNotEmpty
                                          ? Image.network(
                                              firstPhoto,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    height: 200,
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 80,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              height: 200,
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.image,
                                                size: 80,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      Positioned(
                                        top: 15,
                                        right: 12,
                                        child: GestureDetector(
                                          onTap: () => _toggleFavourite(
                                            tripId,
                                            tripData,
                                          ),
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFav
                                                ? Colors.red
                                                : Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width -
                                                150,
                                            child: Text(
                                              tripData['destination'] ?? "Trip",
                                              style: GoogleFonts.quicksand(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isFullyBooked
                                                  ? Colors.red.shade600
                                                  : Colors.green.shade600,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isFullyBooked
                                                      ? Icons.cancel
                                                      : Icons.people,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isFullyBooked
                                                      ? "Full"
                                                      : "$availableSeats Left",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month_rounded,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${tripData['startDate'] ?? '-'} to ${tripData['endDate'] ?? '-'}",
                                            style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.currency_rupee,
                                                size: 16,
                                              ),
                                              Text(
                                                "${tripData['minBudget'] ?? '-'} - ${tripData['maxBudget'] ?? '-'} /person",
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
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
                  }, childCount: trips.length),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedTravelFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TravelChatbotPage()),
          );
        },
      ),
    );
  }
}
