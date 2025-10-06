import 'dart:developer';
import 'package:flutter/material.dart';
// import 'package:motto_app/Home_screen.dart';
import 'package:motto_app/bottom_navigation_screen.dart';
import 'package:motto_app/firstScreen.dart';
//import 'package:motto_app/login_screen.dart';
import 'package:motto_app/shared_preference_screen.dart';

class splashscreen extends StatelessWidget {
  const splashscreen({super.key});

  void navigateToScreen(BuildContext context) {
  Future.delayed(Duration(seconds: 3), () async{
    UserController userControllerObj = UserController();
    await userControllerObj.getSharedPrefData();
    log("IS USER LOGGED IN:${userControllerObj.isUserLoggedIn}");

    if(userControllerObj.isUserLoggedIn){
      //HOME SCREEN
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return BottomNavigationWidget();
        },
      ),
    );
   }else{
    //LOGIN SCREEN
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context){
          return FirstScreen();
        },
      ),
    );
   }
  }
 );
}

  @override
  Widget build(BuildContext context) {
    navigateToScreen(context);
    return Scaffold(
      body: Center(
        child: 
          Image.asset("assets/Motto logo.png"),
        ),
      );
  }
}