import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:motto_app/view/bottom_navigation_screen.dart';
import 'package:motto_app/view/firstScreen.dart';
import 'package:motto_app/controller/shared_preference.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controllers
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _scaleController.forward();
    _fadeController.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () async {
      UserController userControllerObj = UserController();
      await userControllerObj.getSharedPrefData();
      log("IS USER LOGGED IN: ${userControllerObj.isUserLoggedIn}");

      if (mounted) {
        if (userControllerObj.isUserLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BottomNavigationWidget(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const FirstScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              // ✅ Removed outer glow (BoxShadow)
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/Logo.png",
                height: 180,
                width: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
