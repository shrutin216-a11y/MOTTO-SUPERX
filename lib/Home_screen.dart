import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:motto_app/login_screen.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Home Screen", 
        style: TextStyle(fontSize: 30)),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                  return LoginScreen();
                }), (route) => false,
                );
            }, 
            icon: Icon(Icons.logout)),
        ]
      ),
    );
  }
}