import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:e_logbook/presentation/pages/GetStarted/getStartedPage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/configs/theme/appcolor.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.lightBackground, // ✅ Apply gradient here
      ),
      child: SafeArea(
        child: AnimatedSplashScreen(
          splash: Center(
            child: Transform.scale(
              scale: 2.5, // Increase this value to make it bigger
              child: Lottie.asset('assets/animations/Elogbook_Animation.json'),
            ),
          ),
          nextScreen: const GetStartedPage(),
          duration: 3500,
          backgroundColor: Colors.transparent, // ✅ Make it transparent
        ),
      ),
    );
  }
}