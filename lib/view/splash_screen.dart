import 'dart:developer';
import 'package:flutter/material.dart';
// import 'package:motto_app/Home_screen.dart';
import 'package:motto_app/view/bottom_navigation_screen.dart';
import 'package:motto_app/view/firstScreen.dart';
//import 'package:motto_app/login_screen.dart';
import 'package:motto_app/controller/shared_preference.dart';
//import 'package:lottie/lottie.dart';

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
      backgroundColor: Colors.grey[200],
      body: Center(
        child: 
          Container(
            height: 100,
            width: 100,
            child: Image.asset("assets/motto.jpg",fit: BoxFit.cover),
            ),
        ),
      );
  }
}