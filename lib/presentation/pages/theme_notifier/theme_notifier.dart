import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          bool isDarkMode = doc['darkMode'] ?? false;
          value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
        }
      }
    } catch (e) {
      print("Error loading theme: $e");
    }
  }

  void toggleTheme(bool isDark) {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}