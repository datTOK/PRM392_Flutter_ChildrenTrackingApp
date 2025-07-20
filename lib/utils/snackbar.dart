import 'package:flutter/material.dart';

void showAppSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red, int seconds = 3}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: seconds),
    ),
  );
} 