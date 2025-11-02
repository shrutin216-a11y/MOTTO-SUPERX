import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motto_app/view/card_Screen.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _removeFromFavourites(String tripId) async {
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favourites')
        .doc(tripId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Removed from favourites"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Stack(
        children: [
          // Gradient header (same as booking screen)
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            height: 220,
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

          // Decorative icons in background
          Positioned(
            top: 50,
            left: 30,
            child: Icon(
              Icons.favorite_border,
              color: Colors.white.withOpacity(0.3),
              size: 70,
            ),
          ),
          Positioned(
            right: 40,
            top: 90,
            child: Icon(
              Icons.favorite,
              color: Colors.white.withOpacity(0.2),
              size: 60,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Text(
                  "Your Favourite Trips ",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Keep track of trips you love the most",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),

                // MAIN CONTENT
                Expanded(
                  child: user == null
                      ? const Center(
                          child: Text(
                            "Please log in to view your favourites.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('favourites')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                      size: 60,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "No favourite trips yet",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final favourites = snapshot.data!.docs;

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              itemCount: favourites.length,
                              itemBuilder: (context, index) {
                                final favData =
                                    favourites[index].data()
                                        as Map<String, dynamic>;
                                final tripId = favourites[index].id;

                                final photos =
                                    (favData['photoPaths'] as List<dynamic>?)
                                        ?.map((e) => e.toString())
                                        .toList() ??
                                    [];
                                final firstPhoto = photos.isNotEmpty
                                    ? photos[0]
                                    : '';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CardScreen(
                                          tripData: {'id': tripId, ...favData},
                                          tripId: tripId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.withOpacity(0.15),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                          child: Stack(
                                            children: [
                                              firstPhoto.isNotEmpty
                                                  ? Image.network(
                                                      firstPhoto,
                                                      height: 200,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Container(
                                                            height: 200,
                                                            color: Colors
                                                                .grey
                                                                .shade300,
                                                            child: const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 80,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                    )
                                                  : Container(
                                                      height: 200,
                                                      color:
                                                          Colors.grey.shade300,
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
                                                  onTap: () =>
                                                      _removeFromFavourites(
                                                        tripId,
                                                      ),
                                                  child: const Icon(
                                                    Icons.favorite,
                                                    color: Colors.redAccent,
                                                    size: 28,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    favData['destination'] ??
                                                        "Trip",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.teal.shade800,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade600,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.flight,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .calendar_month_rounded,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${favData['startDate'] ?? '-'} to ${favData['endDate'] ?? '-'}",
                                                    style: GoogleFonts.poppins(
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
                                                        color: Colors.black54,
                                                      ),
                                                      Text(
                                                        "${favData['minBudget'] ?? '-'} - ${favData['maxBudget'] ?? '-'} /person",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .teal
                                                                  .shade700,
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
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
