import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  String email = "";
  String passwd = "";
  String mob = "";
  String city = "";
  String name = "";
  String bio = "";
  String profileImage = "";
  bool isUserLoggedIn = false;

  // SET DATA
  Future<void> setSharedPrefData(Map obj) async {
    SharedPreferences sharedPreferencesObj =
        await SharedPreferences.getInstance();
    log("USER DATA MAP $obj");

    // Only overwrite keys that are provided
    if (obj.containsKey('email')) {
      await sharedPreferencesObj.setString("email", obj['email']);
    }
    if (obj.containsKey('mob')) {
      await sharedPreferencesObj.setString("mob", obj['mob']);
    }
    if (obj.containsKey('city')) {
      await sharedPreferencesObj.setString("city", obj['city']);
    }
    if (obj.containsKey('name')) {
      await sharedPreferencesObj.setString("name", obj['name']);
    }
    if (obj.containsKey('bio')) {
      await sharedPreferencesObj.setString("bio", obj['bio']);
    }
    if (obj.containsKey('profileImage')) {
      await sharedPreferencesObj.setString("profileImage", obj['profileImage']);
    }

    await sharedPreferencesObj.setBool("isLogin", true);
    await getSharedPrefData();
  }

  // GET DATA
  Future<void> getSharedPrefData() async {
    SharedPreferences sharedPreferencesObj =
        await SharedPreferences.getInstance();

    email = sharedPreferencesObj.getString("email") ?? "";
    mob = sharedPreferencesObj.getString("mob") ?? "";
    city = sharedPreferencesObj.getString("city") ?? "";
    name = sharedPreferencesObj.getString("name") ?? "";
    bio = sharedPreferencesObj.getString("bio") ?? "";
    profileImage = sharedPreferencesObj.getString("profileImage") ?? "";

    isUserLoggedIn = sharedPreferencesObj.getBool("isLogin") ?? false;

    log("NAME :- $name");
    log("BIO :- $bio");
    log("PROFILE IMAGE PATH :- $profileImage");
  }
}
