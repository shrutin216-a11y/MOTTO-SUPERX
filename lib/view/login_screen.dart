import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motto_app/view/bottom_navigation_screen.dart';
import 'package:motto_app/controller/shared_preference.dart';
import 'package:motto_app/view/signup_screen.dart';
import 'package:motto_app/controller/snackbar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset("assets/login.png"),

                const SizedBox(height: 50),

                /// 🔹 Heading
                const Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Log in to continue your journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                /// 🔹 Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email, color: Colors.black54),
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// 🔹 Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                /// 🔹 Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
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
                      backgroundColor: Colors.green, // Black button
                      foregroundColor: Colors.white, // White text
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

                /// 🔹 Signup Link
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
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
