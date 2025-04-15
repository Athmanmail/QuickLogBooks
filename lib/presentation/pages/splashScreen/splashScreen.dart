import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:e_logbook/presentation/pages/GetStarted/getStartedPage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: AnimatedSplashScreen(
          splash: Center(
            child: Transform.scale(
              scale: 2.5,
              child: Lottie.asset('assets/animations/Elogbook_Animation.json'),
            ),
          ),
          nextScreen: const GetStartedPage(),
          duration: 3500,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}