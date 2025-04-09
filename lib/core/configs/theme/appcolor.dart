import 'package:flutter/material.dart';

class AppColor {
  static const light = Color(0xFFFFFFFF);
  static const primary = Color(0xFFA7BD17);

  static final lightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF), // Your existing lightBackground color
      Color(0xFF50C9CE), // A deeper teal for contrast
    ],
  );

  static const darkBackground = Color(0xFF0D0C0C);
  static const textColor = Color(0xFF00000F);
  static const objects = Color(0xFF000000);

}