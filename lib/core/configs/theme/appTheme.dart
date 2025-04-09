import 'package:flutter/material.dart';

import 'appcolor.dart';

class AppTheme{
  //for the light theme of the application
  static final lightTheme = ThemeData(
    primaryColor: AppColor.primary,
    scaffoldBackgroundColor: AppColor.lightBackground.colors.first, // Using the first color of the gradient as fallback
    brightness: Brightness.light,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
  // dark theme of the application
  static final darkTheme = ThemeData(
      primaryColor: AppColor.primary,
      scaffoldBackgroundColor: AppColor.darkBackground,
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),

          )
      )
  );


}