import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:motto_app/login_screen.dart";
import "package:motto_app/shared_preference_screen.dart";
import "package:shared_preferences/shared_preferences.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  UserController userController = UserController();

  @override
  void initState(){
    super.initState();
    getData();
  }

  void getData() async{
    await userController.getSharedPrefData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen", style: TextStyle(fontSize: 30,color: Colors.pink)),
        actions: [
          IconButton(
            onPressed: () async{
              SharedPreferences sharedPreferencesObj = await SharedPreferences.getInstance();
              sharedPreferencesObj.clear();

              FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                  return LoginScreen();
                }), (route) => false,
                );
            }, 
            icon: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}