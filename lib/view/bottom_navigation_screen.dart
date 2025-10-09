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
        //selectedItemColor: Colors.black,
        //unselectedItemColor: Colors.grey,
        onTap: (value) {
          log("Index: $value");
          currentSelectedIndex = value;
          setState(() {});
        },
        items: [
          BottomBarItem(
            icon: Icon(Icons.public),
            selectedColor: Colors.black,
            title: Text(" "),
            unSelectedColor: Colors.grey,
          ),
          BottomBarItem(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite_sharp),
            selectedColor: Colors.black,
            unSelectedColor: Colors.grey,
            title: Text(" "),
          ),
          // BottomBarItem(
          //   icon: Icon(Icons.add_box),
          //   selectedColor: Colors.black,
          //   unSelectedColor: Colors.grey,
          //   title: Text(" "),
          // ),
          BottomBarItem(
            icon: Icon(Icons.chat),
            unSelectedColor: Colors.grey,
            selectedColor: Colors.black,
            title: Text(" "),
          ),
          BottomBarItem(
            icon: Icon(Icons.account_circle_sharp),
            unSelectedColor: Colors.grey,
            selectedColor: Colors.black,
            title: Text(" "),
          ),
        ],
        option: AnimatedBarOptions(barAnimation: BarAnimation.fade),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.teal,
        //   onPressed: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) {
        //           return StartTrip();
        //         },
        //       ),
        //     );
        //   },
        //   child: const Icon(Icons.add),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  pages(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return Favourites();
      case 2:
        return StartTrip();
      case 3:
        return ChatScreen();
      case 4:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}
