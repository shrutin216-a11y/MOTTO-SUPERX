import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:motto_app/Home_screen.dart';
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
    'assets/image.png',
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
  ];


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
         Align(
            alignment: Alignment.topCenter,
            child: CarouselSlider(
              options: CarouselOptions(
                height: size.height * 0.60,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 1),
                autoPlayAnimationDuration: const Duration(milliseconds: 100),
                enlargeCenterPage: false,
              ),
              items: imageList.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Positioned(
            top: size.height * 0.57, 
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.pink)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink)
                        )
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.pink
                          )
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink)
                        )
                      ),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> data ={
                          'email':emailController.text.trim(),
                          'password':passwordController.text.trim(),
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

                            log("User Crdentials: $userCredentialObj");
                            log("User: ${userCredentialObj.user}");
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
                                builder: (context) => BottomNavigationWidget(),
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
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Sign Up Link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => signupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
