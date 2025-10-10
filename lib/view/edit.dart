import 'package:flutter/material.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Edit", style: TextStyle(fontSize: 25))),
    );
  }
}
