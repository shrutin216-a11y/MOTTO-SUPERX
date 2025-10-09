import 'package:flutter/material.dart';
import 'package:confirmation_success/confirmation_success.dart';
import 'package:motto_app/view/Home_screen.dart';
import 'package:motto_app/view/bottom_navigation_screen.dart'; // example package

class SubmitTrip extends StatefulWidget {
  @override
  State<SubmitTrip> createState() => _SubmitTripState();
}

class _SubmitTripState extends State<SubmitTrip> {
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return BottomNavigationWidget();
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfirmationSuccess(
        reactColor: Colors.green,
        child: Text(
          "   Posted \nSuccesfully! ",
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
