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
      QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .get();

      for (var tripDoc in tripsSnapshot.docs) {
        QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .doc(tripDoc.id)
            .collection('bookings')
            .where('bookedBy', isEqualTo: currentUser!.uid)
            .get();

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
          title: const Text('My Bookings'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'Please login to view your bookings',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 🔹 Updated background UI below
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

          // Main content (scroll view)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header text (replacing SliverAppBar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            SizedBox(width: 35),
                            Text(
                              'My Bookings',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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

                  const SizedBox(height: 50),

                  // Expanded list content
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchUserBookings(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(50),
                              child: CircularProgressIndicator(
                                color: Colors.teal,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Error loading bookings',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final bookings = snapshot.data ?? [];

                        if (bookings.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.event_busy,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No bookings yet',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
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
                          );
                        }

                        // 🔹 Booking list
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            final tripData =
                                booking['tripData'] as Map<String, dynamic>;
                            final bookingData =
                                booking['bookingData'] as Map<String, dynamic>;
                            final passengers =
                                bookingData['passengers'] as List<dynamic>? ??
                                [];
                            final photos =
                                (tripData['photoPaths'] as List<dynamic>?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                [];
                            final firstPhoto = photos.isNotEmpty
                                ? photos[0]
                                : '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
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
                                    child: firstPhoto.isNotEmpty
                                        ? Image.network(
                                            firstPhoto,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  height: 180,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 60,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            height: 180,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.image,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                tripData['destination'] ??
                                                    'Trip',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            _buildStatusChip(
                                              bookingData['status'],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(
                                          Icons.calendar_month,
                                          'Journey Date',
                                          '${tripData['startDate'] ?? '-'} to ${tripData['endDate'] ?? '-'}',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.group,
                                          'Passengers',
                                          '${passengers.length} ${passengers.length == 1 ? 'person' : 'people'}',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.pin_drop_outlined,
                                          'Boarding Point',
                                          tripData['boardingPoint'] ?? 'N/A',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.access_time,
                                          'Booked On',
                                          formatTimestamp(
                                            bookingData['timestamp'],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Divider(color: Colors.grey.shade300),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Passengers:',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...passengers.map((p) {
                                          final cancelled =
                                              p['status'] == 'cancelled';
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  cancelled
                                                      ? Icons.cancel
                                                      : Icons.person,
                                                  size: 16,
                                                  color: cancelled
                                                      ? Colors.red
                                                      : Colors.teal,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    p['name'] ?? 'N/A',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: cancelled
                                                          ? Colors.red
                                                          : Colors
                                                                .grey
                                                                .shade800,
                                                      decoration: cancelled
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _showBookingDetails(
                                                context,
                                                booking,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF00BFA5,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                          },
                        );
                      },
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

  // --- Helper Widgets (unchanged) ---
  Widget _buildStatusChip(String? status) {
    final s = status ?? 'confirmed';
    Color bg = Colors.green.shade50, border = Colors.green, text = Colors.green;
    IconData icon = Icons.check_circle;
    String txt = 'Confirmed';

    if (s == 'cancelled') {
      bg = Colors.red.shade50;
      border = Colors.red;
      text = Colors.red;
      icon = Icons.cancel;
      txt = 'Cancelled';
    } else if (s == 'partial') {
      bg = Colors.orange.shade50;
      border = Colors.orange;
      text = Colors.orange;
      icon = Icons.warning_rounded;
      txt = 'Partial';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 16),
          const SizedBox(width: 4),
          Text(
            txt,
            style: GoogleFonts.poppins(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
        const SizedBox(width: 8),
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
    final tripId = booking['tripId'] as String;
    final bookingId = booking['bookingId'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
                              final isPassengerCancelled =
                                  passenger['status'] == 'cancelled';

                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isPassengerCancelled
                                      ? Colors.red.shade50
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isPassengerCancelled
                                        ? Colors.red.shade200
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                'Passenger ${idx + 1}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (isPassengerCancelled) ...[
                                                SizedBox(width: 8),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'CANCELLED',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (!isPassengerCancelled)
                                          TextButton.icon(
                                            onPressed: () {
                                              _confirmCancelPassenger(
                                                context,
                                                tripId,
                                                bookingId,
                                                idx,
                                                passenger['name'] ??
                                                    'Passenger ${idx + 1}',
                                                passengers.length,
                                                setModalState,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.cancel,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            label: Text(
                                              'Cancel',
                                              style: GoogleFonts.poppins(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                            ),
                                          ),
                                      ],
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
                            }),

                            SizedBox(height: 20),

                            // Cancel Entire Booking Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _confirmCancelBooking(
                                    context,
                                    tripId,
                                    bookingId,
                                  );
                                },
                                icon: Icon(Icons.cancel_outlined),
                                label: Text(
                                  'Cancel Entire Booking',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
              },
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

  void _confirmCancelPassenger(
    BuildContext context,
    String tripId,
    String bookingId,
    int passengerIndex,
    String passengerName,
    int totalPassengers,
    StateSetter setModalState,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Cancel Passenger',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to cancel the booking for $passengerName?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await cancelPassenger(
                  tripId,
                  bookingId,
                  passengerIndex,
                  setModalState,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Yes, Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmCancelBooking(
    BuildContext context,
    String tripId,
    String bookingId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Cancel Booking',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to cancel this entire booking? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await cancelBooking(tripId, bookingId);
                Navigator.pop(context); // Close bottom sheet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Yes, Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelPassenger(
    String tripId,
    String bookingId,
    int passengerIndex,
    StateSetter setModalState,
  ) async {
    try {
      final bookingRef = FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .collection('bookings')
          .doc(bookingId);

      // Get current booking data
      final bookingDoc = await bookingRef.get();
      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingDoc.data() as Map<String, dynamic>;
      List<dynamic> passengers = List.from(bookingData['passengers'] ?? []);

      // Mark the passenger as cancelled instead of removing
      if (passengerIndex >= 0 && passengerIndex < passengers.length) {
        passengers[passengerIndex]['status'] = 'cancelled';

        // Check if all passengers are cancelled
        bool allCancelled = passengers.every((p) => p['status'] == 'cancelled');

        // Update the booking with the modified passenger list
        await bookingRef.update({
          'passengers': passengers,
          'status': allCancelled ? 'cancelled' : 'partial',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Passenger cancelled successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {}); // Refresh main UI
          setModalState(() {}); // Refresh modal UI
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel passenger: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> cancelBooking(String tripId, String bookingId) async {
    try {
      final bookingRef = FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .collection('bookings')
          .doc(bookingId);

      // Soft-cancel booking:
      await bookingRef.update({'status': 'cancelled'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking cancelled successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
