import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motto_app/controller/notification_service.dart';
import 'package:motto_app/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAlE7itPYjgoluoyF_Ihq69eNEa1y0E0f8",
      appId: "1:251210101725:android:989ee2f705690479f13c34",
      messagingSenderId: "251210101725",
      projectId: "project1-c5126",
    ),
  );
  await NotificationService.initialize();

  await FirebaseMessaging.instance.requestPermission();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,

      title: "MOTTO",
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: SplashScreen()),
    );
  }
}
//okayyy