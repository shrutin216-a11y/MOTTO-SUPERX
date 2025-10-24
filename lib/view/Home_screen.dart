import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/view/Favourites.dart';
import 'package:motto_app/view/card_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  final List<String> tabItems = [
    'All',
    'Mountains',
    'Beaches',
    'Hill Station',
    'Desert',
    'Devotional',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
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
                        // 📍 Location row
                        Row(
                          children: [
                            const Icon(
                              Icons.pin_drop_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pune',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Behind Crown Bakery • Narhe, Pune',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Favourites();
                                    },
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.favorite_outline_outlined,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.notifications, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SearchBar(
                          hintText: "Search Spots",
                          leading: const Icon(Icons.search),
                          backgroundColor: const WidgetStatePropertyAll(
                            Colors.white,
                          ),
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

          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 2,
            automaticallyImplyLeading: false,
            toolbarHeight: 15,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemCount: tabItems.length,
                itemBuilder: (context, i) {
                  final isSel = selectedTab == i;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.black : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSel ? Colors.black : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        tabItems[i],
                        style: TextStyle(
                          color: isSel ? Colors.white : Colors.grey.shade900,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: const Text(
                'RECOMMENDED FOR YOU',
                style: TextStyle(
                  letterSpacing: 0.5,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),


          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "No trips available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                final trips = snapshot.data!.docs;

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final trip = trips[index];
                    final tripData = trip.data() as Map<String, dynamic>;
                    final photos =
                        (tripData['photoPaths'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [];
                    final firstPhoto = photos.isNotEmpty ? photos[0] : '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardScreen(
                              tripData: {
                                'id': trip.id, 
                                ...tripData,
                              },
                              tripId:
                                  trip.id, 
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
                                    top: 20,
                                    right: 12,
                                    child: Icon(
                                      Icons.favorite_border_outlined,
                                      color: Colors.white,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        tripData['destination'] ?? "Trip",
                                        style: GoogleFonts.quicksand(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(
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
                  }, childCount: trips.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData? icon) {
    return Material(
      color: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Row(
                  children: [
                    Icon(icon, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                  ],
                ),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
