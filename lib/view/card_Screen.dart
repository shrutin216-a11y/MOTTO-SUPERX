import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/view/booking_screen.dart';

class CardScreen extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final String? tripId; // Add tripId as a separate parameter

  const CardScreen({
    super.key,
    required this.tripData,
    this.tripId, // Optional but recommended
  });

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late final List<String> imageList;
  late final String effectiveTripId;

  @override
  void initState() {
    super.initState();

    // Get tripId from either the parameter or tripData
    effectiveTripId = widget.tripId ?? widget.tripData['id'] ?? '';

    // Debug: Check if tripId is available
    if (effectiveTripId.isEmpty) {
      print('WARNING: No tripId found in CardScreen!');
    } else {
      print('CardScreen initialized with tripId: $effectiveTripId');
    }

    // Safe parsing of photoPaths
    final photosDynamic = widget.tripData['photoPaths'];
    if (photosDynamic is List) {
      imageList = photosDynamic.map((e) => e.toString()).toList();
    } else if (photosDynamic is String) {
      imageList = [photosDynamic];
    } else {
      imageList = [];
    }
  }

  // Helper method to safely convert dynamic data to String
  String _safeToString(dynamic value, String fallback) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: size.height * 0.6,
                              viewportFraction: 1.0,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 2),
                              autoPlayAnimationDuration: const Duration(
                                milliseconds: 1500,
                              ),
                              enlargeCenterPage: false,
                            ),
                            items: imageList.isNotEmpty
                                ? imageList.map((imagePath) {
                                    return Container(
                                      width: size.width,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(imagePath),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    Container(
                                      width: size.width,
                                      height: size.height * 0.6,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                          ),
                          Positioned(
                            top: 50,
                            left: 20,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            right: 20,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.favorite_border_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 400),
                    width: size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Text(
                                    _safeToString(
                                      widget.tripData['destination'],
                                      "Trip",
                                    ),
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.group_outlined,
                                          size: 20,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Max ${widget.tripData['groupSize'] ?? 12} Group Size",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 24,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      color: Colors.grey.shade300,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.currency_rupee,
                                          size: 20,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${widget.tripData['maxBudget']}/ Person",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Boarding Point",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.pin_drop_outlined),
                              Text(
                                _safeToString(
                                  widget.tripData['boardingPoint'],
                                  "",
                                ),
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Date of Journey",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month),
                              Text(
                                "${_safeToString(widget.tripData['startDate'], '-')} to ${_safeToString(widget.tripData['endDate'], '-')}",
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Mode",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.car_rental_outlined),
                              Text(
                                _safeToString(
                                  widget.tripData['mode'],
                                  "Car | Aeroplane",
                                ),
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Description",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _safeToString(
                              widget.tripData['details'],
                              "Trip description goes here.",
                            ),
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Activities",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _safeToString(
                              widget.tripData['activities'],
                              "Trip activities go here.",
                            ),
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              // Validate tripId before navigating
                              if (effectiveTripId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Trip ID not found. Cannot proceed with booking.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    tripData: widget.tripData,
                                    tripId: effectiveTripId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.teal,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset.zero,
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Confirm Your Seat",
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
