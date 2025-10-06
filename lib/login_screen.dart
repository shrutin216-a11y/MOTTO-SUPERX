import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motto_app/bottom_navigation_screen.dart';
import 'package:motto_app/shared_preference_screen.dart';
import 'package:motto_app/signup_screen.dart';
import 'package:motto_app/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserController userController = UserController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final List<String> imageList = [
    'assets/img1.png',
    'assets/img2.png',
    'assets/img3.png',
    'assets/img4.png',
    'assets/img5.png'
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Background Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: size.height,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 2),
              autoPlayAnimationDuration: const Duration(milliseconds: 600),
              enlargeCenterPage: false,
            ),
            items: imageList.map((imagePath) {
              return Container(
                width: size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),

          /// 🔹 Semi-transparent overlay (ignore touches)
          IgnorePointer(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          /// 🔹 Login UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),

                    const Text(
                      "Welcome back!",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Log in to continue your journey",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),

                    /// 🔹 Email Field with prefix icon
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        hintText: "Email",
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// 🔹 Password Field with prefix icon
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height:6),
                    Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                    Text(
                    "Forget Password?",
                     style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                    /// 🔹 Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic> data = {
                            'email': emailController.text.trim(),
                            'password': passwordController.text.trim(),
                            "LoginFlag": true,
                          };
                          userController.setSharedPrefData(data);

                          if (emailController.text.trim().isNotEmpty &&
                              passwordController.text.trim().isNotEmpty) {
                            try {
                              UserCredential userCredentialObj =
                                  await _firebaseAuth.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );

                              log("User Credentials: $userCredentialObj");
                              log("User Id: ${userCredentialObj.user!.uid}");

                              CustomSnackbar().showCustomSnackBar(
                                context,
                                "Login Successful!",
                                bgColor: Colors.green,
                              );

                              emailController.clear();
                              passwordController.clear();

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BottomNavigationWidget(),
                                ),
                              );
                            } on FirebaseAuthException catch (error) {
                              CustomSnackbar().showCustomSnackBar(
                                context,
                                error.message!,
                                bgColor: Colors.red,
                              );
                            }
                          } else {
                            CustomSnackbar().showCustomSnackBar(
                              context,
                              "Enter valid data",
                              bgColor: Colors.red,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    /// 🔹 Signup link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const signupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Create one",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
