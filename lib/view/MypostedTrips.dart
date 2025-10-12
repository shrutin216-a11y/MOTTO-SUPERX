import 'package:flutter/material.dart';

class MypostedTrips extends StatefulWidget {
  const MypostedTrips({super.key});

  @override
  State<MypostedTrips> createState() => _MypostedTripsState();
}

class _MypostedTripsState extends State<MypostedTrips> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My posted Trips", style: TextStyle(fontSize: 30)),
        backgroundColor: Colors.green,
      ),
    );
  }
}
