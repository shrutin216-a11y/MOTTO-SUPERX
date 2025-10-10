import "dart:developer";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:motto_app/view/card_Screen.dart";
import "package:motto_app/view/firstScreen.dart";
import "package:motto_app/controller/shared_preference.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFF8F9FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const accent = Color(0xFF22C55E);
  static const purpleStart = Color(0xFF7C3AED);
  static const purpleEnd = Color(0xFFEC4899);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserController userController = UserController();

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    await userController.getSharedPrefData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: false,
            stretch: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 260,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Colors.green],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              children: const [
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
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.wallet,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'CREDITS ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white24,
                              child: const Text(
                                'A',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SearchBar(
                          leading: const Icon(Icons.search),
                          hintText: "Search Spots",
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

          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeader(
              height: 70,
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const _ScrollableTabs(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _FilterChip(label: 'Filters', icon: Icons.tune),
                  _FilterChip(label: 'Under 30 mins'),
                  _FilterChip(label: 'Under ₹250'),
                  _FilterChip(label: 'Loved by Pune'),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: const Text(
                'RECOMMENDED FOR YOU',
                style: TextStyle(
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: SliverList.builder(
              itemCount: 6,
              itemBuilder: (context, index) => _PlaceCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedHeader extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _PinnedHeader({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeader oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

class _ScrollableTabs extends StatefulWidget {
  const _ScrollableTabs();

  @override
  State<_ScrollableTabs> createState() => _ScrollableTabsState();
}

class _ScrollableTabsState extends State<_ScrollableTabs> {
  int selected = 0;
  final items = const [
    'All',
    'Mountains',
    'Beaches',
    'Hill Station',
    'Desert',
    'Devotional',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final isSel = selected == i;
        return GestureDetector(
          onTap: () => setState(() => selected = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? Colors.black : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSel ? Colors.black : Colors.grey.shade300,
              ),
            ),
            child: Text(
              items[i],
              style: TextStyle(
                color: isSel ? Colors.white : AppColors.textPrimary,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _FilterChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
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
                    Icon(icon, size: 16, color: AppColors.textSecondary),
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

class _PlaceCard extends StatelessWidget {
  final int index;
  const _PlaceCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CardScreen()),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
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
              child: Image.network(
                "https://skyhookcontentful.imgix.net/6MPvB1nbHtL2AQbxMi2D7y/af0829fe9fc4733a754e15705d99d33d/pixabay-pehrlich-himalayas.jpg?auto=compress,format,enhance&crop=faces,center&fit=crop&ar=1:1&w=576px&ixlib=react-9.10.0",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Mount Fuji",
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
                          borderRadius: BorderRadius.circular(6),
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
                        "7 days  •  8 Nights",
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee, size: 16),
                          Text(
                            "8000/person",
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
  }
}
