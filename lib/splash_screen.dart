import 'package:flutter/material.dart';
import 'package:motto_app/login_screen.dart';

class splashscreen extends StatelessWidget {
  const splashscreen({super.key});

  void navigateToScreen(BuildContext context) {
  Future.delayed(Duration(seconds: 5), () {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return LoginScreen();
        }
      )
    );
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