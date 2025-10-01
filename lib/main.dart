import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:motto_app/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options:FirebaseOptions(
      apiKey: "AIzaSyAlE7itPYjgoluoyF_Ihq69eNEa1y0E0f8", 
      appId: "1:251210101725:android:989ee2f705690479f13c34", 
      messagingSenderId: "251210101725", 
      projectId: "project1-c5126",
    )
 );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: splashscreen(),
      ),
    );
  }
}
