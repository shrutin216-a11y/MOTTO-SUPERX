import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  String email = "";
  String passwd = "";
  bool isUserLoggedIn = false;

  //SET DATA
  void setSharedPrefData(Map<String, dynamic> obj) async {
    SharedPreferences sharedPreferencesObj =
        await SharedPreferences.getInstance();

    await sharedPreferencesObj.setString("email", obj['email']);
    await sharedPreferencesObj.setString("password", obj['password']);
    await sharedPreferencesObj.setBool("isUserLoggedIn", obj['LoginFlag']);
  }

  //GET DATA
  Future<void> getSharedPrefData() async {
    SharedPreferences sharedPreferencesObj =
        await SharedPreferences.getInstance();

    email = sharedPreferencesObj.getString("email") ?? "";
    passwd = sharedPreferencesObj.getString("password") ?? "";
    isUserLoggedIn = sharedPreferencesObj.getBool("isUserLoggedIn") ?? false;
  }
}
