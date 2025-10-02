import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:motto_app/courses_screen.dart';
import 'package:motto_app/dynamic_gridview.dart';
import 'package:motto_app/profile_screen.dart';
import 'package:motto_app/static_gridview.dart';

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
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          log("Index: $value");
          currentSelectedIndex = value;
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: "Notification",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
        ],
      ),
    );
  }

  pages(int index) {
    switch (index) {
      case 0:
        return StaticGridview();
      case 1:
        return DynamicGridview();
      case 2:
        return ProfileScreen();
      case 3:
        return CoursesScreen();
      default:
        return Container();
    }
  }
}
