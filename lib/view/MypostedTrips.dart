import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyPostedTripsScreen extends StatefulWidget {
  const MyPostedTripsScreen({super.key});

  @override
  State<MyPostedTripsScreen> createState() => _MyPostedTripsScreenState();
}

class _MyPostedTripsScreenState extends State<MyPostedTripsScreen>
    with SingleTickerProviderStateMixin {
  final currentUser = FirebaseAuth.instance.currentUser;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  Stream<QuerySnapshot> getMyPostedTrips() {
    if (currentUser == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('trips')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> cancelTrip(String tripId) async {
    try {
      final tripRef = FirebaseFirestore.instance.collection('trips').doc(tripId);
      final bookingsRef = tripRef.collection('bookings');

      // Get all bookings under this trip
      final bookingsSnapshot = await bookingsRef.get();

      // Start a batch operation
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete all bookings first
      for (var doc in bookingsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the trip document itself
      batch.delete(tripRef);

      // Commit all deletes together
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip and all bookings cancelled successfully!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      log('trip cancelled successfully');
    } catch (e) {
      log('Error cancelling trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel trip: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getTripBookings(String tripId) async {
    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .collection('bookings')
          .orderBy('timestamp', descending: true)
          .get();

      return bookingsSnapshot.docs.map((doc) {
        return {'bookingId': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // Get count of active bookings only
  Future<int> getActiveBookingsCount(String tripId) async {
    try {
      List<Map<String, dynamic>> allBookings = await getTripBookings(tripId);
      return allBookings.where((booking) {
        final status = booking['status'] ?? 'confirmed';
        return status != 'cancelled';
      }).length;
    } catch (e) {
      return 0;
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  void showBookingsBottomSheet(
    BuildContext context,
    String tripId,
    String tripName,
  ) async {
    List<Map<String, dynamic>> bookings = await getTripBookings(tripId);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Bookings for',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          tripName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  if (bookings.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No bookings yet',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Waiting for travelers to book this trip',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          final passengers =
                              booking['passengers'] as List<dynamic>? ?? [];
                          final bookingStatus = booking['status'] ?? 'confirmed';
                          final isBookingCancelled = bookingStatus == 'cancelled';
                          final isPartialBooking = bookingStatus == 'partial';

                          // Count active passengers
                          int activePassengers = passengers
                              .where(
                                (p) => (p['status'] ?? 'confirmed') != 'cancelled',
                              )
                              .length;

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isBookingCancelled
                                    ? Colors.red.shade200
                                    : isPartialBooking
                                        ? Colors.orange.shade200
                                        : Colors.teal.shade100,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isBookingCancelled
                                              ? Colors.red
                                              : isPartialBooking
                                                  ? Colors.orange
                                                  : Colors.teal)
                                          .withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.all(16),
                                childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                leading: CircleAvatar(
                                  backgroundColor: isBookingCancelled
                                      ? Colors.red.shade100
                                      : isPartialBooking
                                          ? Colors.orange.shade100
                                          : Colors.teal.shade100,
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: isBookingCancelled
                                          ? Colors.red.shade900
                                          : isPartialBooking
                                              ? Colors.orange.shade900
                                              : Colors.teal.shade900,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        passengers.isNotEmpty ? passengers[0]['name'] ?? 'Traveler' : 'Traveler',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isBookingCancelled)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'CANCELLED',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    if (isPartialBooking)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'PARTIAL',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.group, size: 16, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          isBookingCancelled
                                              ? '${passengers.length} ${passengers.length == 1 ? 'person' : 'people'} (All Cancelled)'
                                              : isPartialBooking
                                                  ? '$activePassengers active of ${passengers.length} ${passengers.length == 1 ? 'person' : 'people'}'
                                                  : '${passengers.length} ${passengers.length == 1 ? 'person' : 'people'}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          formatTimestamp(booking['timestamp']),
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.expand_more,
                                  color: isBookingCancelled
                                      ? Colors.red
                                      : isPartialBooking
                                          ? Colors.orange
                                          : Colors.teal,
                                ),
                                children: [
                                  Divider(thickness: 1),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.email, size: 18, color: Colors.teal),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          booking['bookedByEmail'] ?? 'N/A',
                                          style: GoogleFonts.poppins(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Passengers:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade900,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ...passengers.map((passenger) {
                                    final passengerStatus = passenger['status'] ?? 'confirmed';
                                    final isPassengerCancelled = passengerStatus == 'cancelled';

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isPassengerCancelled ? Colors.red.shade50 : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isPassengerCancelled ? Colors.red.shade200 : Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildPassengerInfo(Icons.person, 'Name', passenger['name'] ?? 'N/A'),
                                                  ],
                                                ),
                                              ),
                                              if (isPassengerCancelled)
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    'CANCELLED',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          _buildPassengerInfo(Icons.cake, 'Age', passenger['age']?.toString() ?? 'N/A'),
                                          _buildPassengerInfo(Icons.wc, 'Gender', passenger['gender'] ?? 'N/A'),
                                          _buildPassengerInfo(Icons.phone, 'Contact', passenger['contact'] ?? 'N/A'),
                                          _buildPassengerInfo(Icons.email_outlined, 'Email', passenger['email'] ?? 'N/A'),
                                          _buildPassengerInfo(Icons.credit_card, 'ID', '${passenger['idType'] ?? 'N/A'} - ${passenger['idNumber'] ?? 'N/A'}'),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPassengerInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal.shade700),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Posted Trips'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Please login to view your posted trips',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Profile-style gradient header
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BFA5), Color(0xFF4DB6AC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "My Posted Trips",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Manage your trips and view bookings",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  // Added extra space below the header to separate header and trip cards
                  const SizedBox(height: 30),

                  // Trips list starts below header (no overlap)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.transparent,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: getMyPostedTrips(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: CircularProgressIndicator(color: Colors.teal),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                                      SizedBox(height: 16),
                                      Text('Error loading trips', style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          final trips = snapshot.data?.docs ?? [];

                          if (trips.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(50),
                                child: Column(
                                  children: [
                                    Icon(Icons.add_location_alt_outlined, size: 80, color: Colors.grey),
                                    SizedBox(height: 20),
                                    Text('No trips posted yet', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey)),
                                    SizedBox(height: 8),
                                    Text('Start creating trips to see them here!', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16, top: 8),
                            itemCount: trips.length,
                            itemBuilder: (context, index) {
                              final trip = trips[index];
                              final tripData = trip.data() as Map<String, dynamic>;
                              final photos = (tripData['photoPaths'] as List<dynamic>?)
                                      ?.map((e) => e.toString())
                                      .toList() ??
                                  [];
                              final firstPhoto = photos.isNotEmpty ? photos[0] : '';

                              return FutureBuilder<int>(
                                future: getActiveBookingsCount(trip.id),
                                builder: (context, bookingSnapshot) {
                                  final bookingCount = bookingSnapshot.data ?? 0;

                                  return GestureDetector(
                                    onTap: () {
                                      showBookingsBottomSheet(context, trip.id, tripData['destination'] ?? 'Trip');
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                                child: firstPhoto.isNotEmpty
                                                    ? Image.network(
                                                        firstPhoto,
                                                        height: 180,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: 180,
                                                        color: Colors.grey.shade300,
                                                        child: Icon(Icons.image, size: 60, color: Colors.grey),
                                                      ),
                                              ),
                                              Positioned(
                                                top: 12,
                                                right: 12,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal.withOpacity(0.9),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.people, color: Colors.white, size: 16),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        '$bookingCount Active ${bookingCount == 1 ? 'Booking' : 'Bookings'}',
                                                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(tripData['destination'] ?? 'Trip', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                                                    SizedBox(width: 6),
                                                    Text('${tripData['startDate'] ?? '-'} to ${tripData['endDate'] ?? '-'}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                                                  ],
                                                ),
                                                SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.group, size: 16, color: Colors.grey),
                                                    SizedBox(width: 6),
                                                    Text('Max ${tripData['groupSize'] ?? 0} people', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                                                    Spacer(),
                                                    Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                                                    Text('${tripData['minBudget'] ?? '-'} - ${tripData['maxBudget'] ?? '-'}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                                                  ],
                                                ),
                                                SizedBox(height: 12),
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal.shade50,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.touch_app, size: 18, color: Colors.teal.shade700),
                                                      SizedBox(width: 8),
                                                      Text('Tap to view bookings', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.teal.shade700)),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: Text('Cancel Trip?'),
                                                        content: Text('Are you sure you want to cancel this trip? This action cannot be undone.'),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                                                          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes, Cancel')),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      await cancelTrip(trip.id);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade50,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.cancel, size: 18, color: Colors.redAccent),
                                                        SizedBox(width: 8),
                                                        Text('Cancel Trip', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                                                      ],
                                                    ),
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
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
