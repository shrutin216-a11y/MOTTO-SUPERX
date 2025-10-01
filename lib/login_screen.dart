import 'dart:developer';
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Login Screen", style: TextStyle(fontSize: 30)),
              SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
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
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
