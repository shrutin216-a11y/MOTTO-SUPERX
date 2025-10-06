import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:motto_app/view/Home_screen.dart';
import 'package:motto_app/view/Favourites.dart';
import 'package:motto_app/view/StartTrip.dart';
import 'package:motto_app/view/profile_screen.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentSelectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[800],
        onTap: (value) {
          log("Index: $value");
          currentSelectedIndex = value;
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.public), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Start Trip",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_sharp), label: "Likes"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_sharp), label: "Profile"),
        ],
      ),
    );
  }

  pages(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return StartTrip();
      case 2:
        return Favourites();
      case 3:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}
