import 'package:e_logbook/presentation/pages/Login_page/login_page.dart';
import 'package:e_logbook/presentation/pages/home_page/home_page.dart';
import 'package:e_logbook/presentation/pages/splashScreen/splashScreen.dart';
import 'package:e_logbook/presentation/pages/theme_notifier/theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/configs/theme/appTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          String name = userDoc['name'] ?? 'User';
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userName', name);
          return MyHomePage(title: name, userName: name);
        }
      }
      await FirebaseAuth.instance.signOut();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userName = prefs.getString('userName') ?? 'User';

    if (isLoggedIn) {
      return const LoginPage();
    } else {
      return const SplashScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'E-Logbook',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.value,
            home: FutureBuilder<Widget>(
              future: _getInitialScreen(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return const Scaffold(
                //     body: Center(child: CircularProgressIndicator()),
                //   );
                // }
                return snapshot.data ?? const SplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}