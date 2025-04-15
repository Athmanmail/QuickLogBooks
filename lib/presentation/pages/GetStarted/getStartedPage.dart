import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/configs/theme/appcolor.dart';
import '../login_page/login_page.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<String> _images = [
    'assets/image/GT3-No-BG.png',
    'assets/image/GT-No-BG.png',
    'assets/image/GT2-NO-BG.png',
  ];

  final List<String> _titles = [
    'Welcome to Q-Logbook',
    'Quick Supervision',
    'Achieve Your Goals',
  ];

  final List<String> _subtitles = [
    'Your learning journey starts here.',
    'Get instant feedback on your progress.',
    'Track your progress and become your best self.',
  ];

  void _nextPage() {
    if (_currentIndex < _images.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text("Quick LogBooks", style: TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: theme.primaryColorLight,
                        fontFamily: "OoohBaby"
                      ),),
                      const SizedBox(height: 115),
                      Image.asset(
                        _images[index],
                        height: 280,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _titles[index],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: theme.primaryColorLight,
                          fontFamily: "Asul"
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _subtitles[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          color: theme.primaryColor,
                          fontFamily: "Caveat",
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _images.length,
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: AppColor.navbarLight,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.navbarLight,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Next",
                          style: TextStyle(color: AppColor.light),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: AppColor.light),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
