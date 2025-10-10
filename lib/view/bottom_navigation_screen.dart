import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:motto_app/view/Home_screen.dart';
import 'package:motto_app/view/Favourites.dart';
import 'package:motto_app/view/StartTrip.dart';
import 'package:motto_app/view/chat.dart';
import 'package:motto_app/view/profile_screen.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int currentSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          _bottomBarItem(Icons.public, 0),
          _bottomBarItem(Icons.favorite_outline, 1,
              selectedIcon: Icons.favorite_sharp),
          _bottomBarItem(Icons.add_circle, 2, selectedIcon: Icons.add_circle),
          _bottomBarItem(Icons.chat, 3),
          _bottomBarItem(Icons.account_circle_sharp, 4),
        ],
        option: AnimatedBarOptions(
          barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.Default,
        ),
      ),
    );
  }

  // 🌊 Ripple + Jump + Glow Animation
  BottomBarItem _bottomBarItem(IconData icon, int index,
      {IconData? selectedIcon}) {
    bool isSelected = currentSelectedIndex == index;

    return BottomBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isSelected ? 28 : 0,
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            // Icon animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final scale = 1 + 0.25 * value; // pop effect
                final offsetY = -8 * value; // jump upward
                final rippleSize = 40 + (value * 30); // ripple expanding
                final rippleOpacity = (1 - value).clamp(0.0, 0.3);

                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 🌟 Expanding ripple circle
                      Container(
                        width: rippleSize,
                        height: rippleSize,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.withOpacity(rippleOpacity)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Icon pop animation
                      AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          isSelected ? (selectedIcon ?? icon) : icon,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
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
        return const HomeScreen();
      case 1:
        return const Favourites();
      case 2:
        return const StartTrip();
      case 3:
        return const ChatScreen();
      case 4:
        return const ProfileScreen();
      default:
        return Container();
    }
  }
}
