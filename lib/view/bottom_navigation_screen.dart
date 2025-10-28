import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motto_app/view/MypostedTrips.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:motto_app/view/Home_screen.dart';
import 'package:motto_app/view/StartTrip.dart';
import 'package:motto_app/view/chat.dart';
import 'package:flutter/services.dart';
import 'package:motto_app/view/profile_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int currentSelectedIndex = 0;

  void resetToHome() {
    if (currentSelectedIndex != 0) {
      setState(() {
        currentSelectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // we'll handle back manually
      onPopInvokedWithResult: (didPop, _) {
        // ✅ If NOT on Home → Go to Home
        if (currentSelectedIndex != 0) {
          setState(() {
            currentSelectedIndex = 0;
          });
          return;
        }

        // ✅ If already on Home → Exit app cleanly
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: pages(currentSelectedIndex),
        bottomNavigationBar: StylishBottomBar(
          currentIndex: currentSelectedIndex,
          onTap: (value) {
            log("Index: $value");
            setState(() {
              currentSelectedIndex = value;
            });
          },
          items: [
            _bottomBarItem(Icons.public_sharp, 0, label: "Explore"),
            _bottomBarItem(
              CupertinoIcons.chat_bubble_2_fill,
              1,
              selectedIcon: CupertinoIcons.chat_bubble_2_fill,
              label: "Chat",
            ),
            _bottomBarItem(
              Icons.navigation_outlined,
              2,
              selectedIcon: Icons.alt_route_rounded,
              label: "Start Trip",
            ),
            _bottomBarItem(
              Icons.terrain_rounded,
              3,
              selectedIcon: Icons.terrain_rounded,
              label: "My Trips",
            ),

            _bottomBarItem(
              Icons.account_circle_outlined,
              4,
              selectedIcon: Icons.account_circle_rounded,
              label: "Profile",
            ),
          ],
          option: AnimatedBarOptions(
            barAnimation: BarAnimation.fade,
            iconStyle: IconStyle.Default,
          ),
        ),
      ),
    );
  }

  // 🌊 Animated Bottom Bar Item
  BottomBarItem _bottomBarItem(
    IconData icon,
    int index, {
    IconData? selectedIcon,
    String? label,
  }) {
    bool isSelected = currentSelectedIndex == index;

    return BottomBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isSelected ? 28 : 0,
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF00BFA5), Color(0xFF4DB6AC)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            // Icon animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final scale = 1 + 0.25 * value;
                final offsetY = -6 * value;
                final glow = Colors.tealAccent.withOpacity(value * 0.3);

                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? glow : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Transform.scale(
                        scale: scale,
                        child: Icon(
                          isSelected ? (selectedIcon ?? icon) : icon,
                          size: isSelected ? 28 : 26,
                          color: isSelected
                              ? const Color(0xFF00695C)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Label animation
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 13 : 12,
                color: isSelected
                    ? const Color(0xFF004D40)
                    : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label ?? ""),
            ),
          ],
        ),
      ),
      title: const Text(" "),
      selectedColor: Colors.black,
      unSelectedColor: Colors.grey,
    );
  }

  // ✅ Page Navigation
  Widget pages(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(); // Explore Page
      case 1:
        return const ChatScreen(receiverId: '',receiverName: '',); // Favourites Page
      case 2:
        return const StartTrip(); // Start Trip Page
      case 3:
        return const MyPostedTripsScreen(); // Chat Page
      case 4:
        return const ProfileScreen(); // Profile Page
      default:
        return Container();
    }
  }
}
