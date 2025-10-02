import "dart:developer";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:motto_app/snackbar.dart";

class signupScreen extends StatelessWidget {
  const signupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
          Positioned(
            top: 640,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.teal)
                //color: Colors.teal[50],
              ),
              child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Create your Account!", style: TextStyle(fontSize: 30,color: Colors.teal)),
              SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Enter your EmailId",
                  // hintText: "Enter Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    
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
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.trim().isNotEmpty &&
                      passwordController.text.trim().isNotEmpty) {
                    try {
                      ///create new user
                      UserCredential userCredentialObj = await firebaseAuth
                          .createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );

                      log("User Credentials : $userCredentialObj");
                      CustomSnackbar().showCustomSnackBar(
                        context,
                        "Registered Successfully!",
                        bgColor: Colors.green,
                      );
                      Navigator.of(context).pop();
                    } on FirebaseAuthException catch (error) {
                      log("Error Code: ${error.code}");
                      log("Error Message: ${error.message}");
                      if (error.code.toString() == "invalid-email") {
                        CustomSnackbar().showCustomSnackBar(
                          context,
                          "Enter valid email id",
                          bgColor: Colors.red,
                        );
                      } else {
                        CustomSnackbar().showCustomSnackBar(
                          context,
                          "error.message!",
                          bgColor: Colors.red,
                        );
                      }
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
                child: Text("SignUp",style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),



            )
        ],

      )
      // backgroundColor: Colors.teal[50],
      // body: Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(10.0),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         Text("SignUp Screen", style: TextStyle(fontSize: 30,color: Colors.teal)),
      //         SizedBox(height: 15),
      //         TextField(
      //           controller: emailController,
      //           decoration: InputDecoration(
      //             labelText: "Enter your EmailId",
      //             // hintText: "Enter Email",
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(10.0),
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 15),
      //         TextField(
      //           controller: passwordController,
      //           decoration: InputDecoration(
      //             labelText: "Password",
      //             //hintText: "Enter Password",
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(10.0),
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 15),
      //         ElevatedButton(
      //           onPressed: () async {
      //             if (emailController.text.trim().isNotEmpty &&
      //                 passwordController.text.trim().isNotEmpty) {
      //               try {
      //                 ///create new user
      //                 UserCredential userCredentialObj = await firebaseAuth
      //                     .createUserWithEmailAndPassword(
      //                       email: emailController.text,
      //                       password: passwordController.text,
      //                     );

      //                 log("User Credentials : $userCredentialObj");
      //                 CustomSnackbar().showCustomSnackBar(
      //                   context,
      //                   "Registered Successfully!",
      //                   bgColor: Colors.green,
      //                 );
      //                 Navigator.of(context).pop();
      //               } on FirebaseAuthException catch (error) {
      //                 log("Error Code: ${error.code}");
      //                 log("Error Message: ${error.message}");
      //                 if (error.code.toString() == "invalid-email") {
      //                   CustomSnackbar().showCustomSnackBar(
      //                     context,
      //                     "Enter valid email id",
      //                     bgColor: Colors.red,
      //                   );
      //                 } else {
      //                   CustomSnackbar().showCustomSnackBar(
      //                     context,
      //                     "error.message!",
      //                     bgColor: Colors.red,
      //                   );
      //                 }
      //               }
      //             } else {
      //               CustomSnackbar().showCustomSnackBar(
      //                 context,
      //                 "Enter valid data",
      //                 bgColor: Colors.red,
      //               );
      //             }
      //           },
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: Colors.teal,
      //             foregroundColor: Colors.teal[50],
      //           ),
      //           child: Text("SignUp",style: TextStyle(fontSize: 20)),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
