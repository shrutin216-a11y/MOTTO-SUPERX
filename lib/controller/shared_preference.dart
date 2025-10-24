import 'dart:developer';


import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  String email = "";
  String passwd = "";
  String mob = "";
  String city = "";
  String name = "";
  bool isUserLoggedIn = false;

  //SET DATA
  Future<void> setSharedPrefData(Map obj) async {
    SharedPreferences sharedPreferencesObj =
        await SharedPreferences.getInstance();
    log("USER DATA MAP $obj");
    await sharedPreferencesObj.setString("email", obj['email']);
    await sharedPreferencesObj.setString("mob", obj['mob']);
    await sharedPreferencesObj.setString("city", obj['city']);
    await sharedPreferencesObj.setString("name", obj['name']);

    await sharedPreferencesObj.setBool("isLogin", true);
    await getSharedPrefData();
  }

  //GET DATA
  Future<void> getSharedPrefData() async {
    SharedPreferences sharedPreferencesObj =
        await SharedPreferences.getInstance();

    email = sharedPreferencesObj.getString("email") ?? "";
    mob = sharedPreferencesObj.getString("mob") ?? "";
    city = sharedPreferencesObj.getString("city") ?? "";
    name = sharedPreferencesObj.getString("name") ?? "";

    isUserLoggedIn = sharedPreferencesObj.getBool("isLogin") ?? false;

    log("NAME :- $name");
  }
}
