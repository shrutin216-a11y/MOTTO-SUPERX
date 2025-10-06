import 'package:flutter/material.dart';
import 'package:confirmation_success/confirmation_success.dart';
import 'package:motto_app/view/Home_screen.dart'; // example package

class SubmitPage extends StatefulWidget {
  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen();
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
          "   Booked \nSuccesfully! ",
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
