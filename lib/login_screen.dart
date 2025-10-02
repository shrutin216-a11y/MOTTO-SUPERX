import 'dart:developer';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motto_app/Home_screen.dart';
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

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Background image with blur
          SizedBox.expand(
            child: Image.network(
              "https://i.pinimg.com/736x/4e/30/f1/4e30f151f42730f7ee16c8650f4a2d74.jpg", // replace with your asset image
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Apply blur filter
          // Positioned.fill(
          //   child: BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), // blur intensity
          //     child: Container(
          //       color: Colors.black.withOpacity(0.2), // dark overlay
          //     ),
          //   ),
          // ),

          /// 🔹 Text over background
          Positioned(
            top: 250,
            left: 20,
            right: 0,
            child: Center(
              child: Text(
                "“Meet people, make plans, travel the world together.”",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 590,
            child: Container(
            width: MediaQuery.of(context).size.width, 
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.teal),
            color: Colors.teal[50],
              ),
            child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Login", style: TextStyle (fontSize: 30,color: Colors.teal)),
              SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email ID",
                  //hintText: "Enter Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  //hintText: "Enter Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.trim().isNotEmpty &&
                      passwordController.text.trim().isNotEmpty) {
                    try {
                      UserCredential userCredentialObj = await _firebaseAuth
                          .signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );

                      log("User Crdentials: $userCredentialObj");
                      log("User: ${userCredentialObj.user}");

                      log("User Id: ${userCredentialObj.user!.uid}");
                      CustomSnackbar().showCustomSnackBar(
                        context,
                        "Login Succesful!",
                        bgColor: Colors.green,
                      );

                      //clear controllers
                      emailController.clear();
                      passwordController.clear();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) {
                            return HomeScreen();
                          },
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
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.teal[50],
                ),
                child: Text("Login", style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return signupScreen();
                      },
                    ),
                  );
                },
                child: Text(
                  "New User? Sign Up",
                  style: TextStyle(fontSize: 18,color: Colors.teal),
                ),
              ),
              SizedBox(height:30)
            ],
          ),
        ),
      ),
          ),
      ]
    ),
    );
  }
}
