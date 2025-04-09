import 'package:e_logbook/presentation/pages/login_page/login_page.dart';
import 'package:flutter/material.dart';

import '../../../core/configs/theme/appcolor.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.lightBackground, // ✅ Apply the gradient here
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // ✅ Make Scaffold transparent
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage("assets/image/quickbookslogo.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Text(
              "Welcome to Quick Log Books",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.normal,
                color: AppColor.textColor,
              ),
            ),
            Image.asset("assets/image/GetStartedNoBg.png"),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: AppColor.textColor,
                        fixedSize: const Size.fromHeight(40),
                      ),
                      child: const Text("Get Started"),
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Get started with "),
                Text("Quick Log Books", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
