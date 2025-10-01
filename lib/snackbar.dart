import 'package:flutter/material.dart';

class CustomSnackbar {
  showCustomSnackBar(
    BuildContext context,
    String message,{
    Color bgColor = Colors.green,
    }) {
      ScaffoldMessenger.of(context,).showSnackBar(
        SnackBar(content: Text(message),
        backgroundColor: bgColor));
    }
}