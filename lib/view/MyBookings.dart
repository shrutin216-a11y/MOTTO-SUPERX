import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    if (currentUser == null) return [];

    List<Map<String, dynamic>> userBookings = [];

    try {
      // Get all trips
      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .get();

      // For each trip, get bookings made by current user
      for (var tripDoc in tripsSnapshot.docs) {
        QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(tripDoc.id)
            .collection('bookings')
            .where('bookedBy', isEqualTo: currentUser!.uid)
            .get();

        // Add each booking with trip details
        for (var bookingDoc in bookingsSnapshot.docs) {
          Map<String, dynamic> tripData =
              tripDoc.data() as Map<String, dynamic>;
          Map<String, dynamic> bookingData =
              bookingDoc.data() as Map<String, dynamic>;

          userBookings.add({
            'bookingId': bookingDoc.id,
            'tripId': tripDoc.id,
            'tripData': tripData,
            'bookingData': bookingData,
          });
        }
      }

      // Sort by timestamp (newest first)
      userBookings.sort((a, b) {
        Timestamp? aTime = a['bookingData']['timestamp'];
        Timestamp? bTime = b['bookingData']['timestamp'];
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return userBookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Bookings'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Please login to view your bookings',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'My Bookings',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'View all your trip bookings',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bookings List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchUserBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: CircularProgressIndicator(color: Colors.teal),
                      ),
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
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error loading bookings',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final bookings = snapshot.data ?? [];

                if (bookings.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: Column(
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
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start exploring and book your first trip!',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final booking = bookings[index];
                    final tripData =
                        booking['tripData'] as Map<String, dynamic>;
                    final bookingData =
                        booking['bookingData'] as Map<String, dynamic>;
                    final passengers =
                        bookingData['passengers'] as List<dynamic>? ?? [];

                    // Get first photo
                    final photos =
                        (tripData['photoPaths'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [];
                    final firstPhoto = photos.isNotEmpty ? photos[0] : '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                          // Trip Image
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: firstPhoto.isNotEmpty
                                ? Image.network(
                                    firstPhoto,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      color: Colors.grey.shade300,
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 180,
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Trip Name & Status
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tripData['destination'] ?? 'Trip',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Confirmed',
                                            style: GoogleFonts.poppins(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                // Booking Details
                                _buildInfoRow(
                                  Icons.calendar_month,
                                  'Journey Date',
                                  '${tripData['startDate'] ?? '-'} to ${tripData['endDate'] ?? '-'}',
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.group,
                                  'Passengers',
                                  '${passengers.length} ${passengers.length == 1 ? 'person' : 'people'}',
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.pin_drop_outlined,
                                  'Boarding Point',
                                  tripData['boardingPoint'] ?? 'N/A',
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.access_time,
                                  'Booked On',
                                  formatTimestamp(bookingData['timestamp']),
                                ),

                                SizedBox(height: 16),
                                Divider(),
                                SizedBox(height: 8),

                                // Passenger Names
                                Text(
                                  'Passengers:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...passengers.map((passenger) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.teal,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          passenger['name'] ?? 'N/A',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                SizedBox(height: 16),

                                // View Details Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showBookingDetails(context, booking);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'View Full Details',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: bookings.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
    final tripData = booking['tripData'] as Map<String, dynamic>;
    final bookingData = booking['bookingData'] as Map<String, dynamic>;
    final passengers = bookingData['passengers'] as List<dynamic>? ?? [];

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
                    child: Text(
                      'Booking Details',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(20),
                      children: [
                        Text(
                          'Trip Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildDetailItem(
                          'Destination',
                          tripData['destination'] ?? 'N/A',
                        ),
                        _buildDetailItem(
                          'Boarding Point',
                          tripData['boardingPoint'] ?? 'N/A',
                        ),
                        _buildDetailItem(
                          'Start Date',
                          tripData['startDate'] ?? 'N/A',
                        ),
                        _buildDetailItem(
                          'End Date',
                          tripData['endDate'] ?? 'N/A',
                        ),
                        _buildDetailItem('Mode', tripData['mode'] ?? 'N/A'),
                        _buildDetailItem(
                          'Budget',
                          '₹${tripData['minBudget'] ?? '-'} - ₹${tripData['maxBudget'] ?? '-'}',
                        ),

                        SizedBox(height: 20),
                        Text(
                          'Passenger Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        SizedBox(height: 12),

                        ...passengers.asMap().entries.map((entry) {
                          int idx = entry.key;
                          Map<String, dynamic> passenger = entry.value;

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Passenger ${idx + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildDetailItem(
                                  'Name',
                                  passenger['name'] ?? 'N/A',
                                ),
                                _buildDetailItem(
                                  'Age',
                                  passenger['age'] ?? 'N/A',
                                ),
                                _buildDetailItem(
                                  'Gender',
                                  passenger['gender'] ?? 'N/A',
                                ),
                                _buildDetailItem(
                                  'Contact',
                                  passenger['contact'] ?? 'N/A',
                                ),
                                _buildDetailItem(
                                  'Email',
                                  passenger['email'] ?? 'N/A',
                                ),
                                _buildDetailItem(
                                  'ID Type',
                                  passenger['idType'] ?? 'N/A',
                                ),
                                _buildDetailItem(
                                  'ID Number',
                                  passenger['idNumber'] ?? 'N/A',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
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

  Widget _buildDetailItem(String label, dynamic value) {
    String displayValue;

    if (value == null) {
      displayValue = 'N/A';
    } else if (value is List) {
      // Convert list to comma-separated string
      displayValue = value.join(', ');
    } else if (value is Map) {
      // Convert map to readable format
      displayValue = value.toString();
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}