import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/configs/theme/appcolor.dart';
import '../home_page/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Firebase login method
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to homepage on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: "E-LogBook"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.lightBackground,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _page(),
      ),
    );
  }

  Widget _page() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _icon(),
                  const SizedBox(height: 50),
                  _inputField("Email", usernameController),
                  const SizedBox(height: 20),
                  _inputField("Password", passwordController, isPassword: true),
                  const SizedBox(height: 50),
                  _loginBtn(),
                  const SizedBox(height: 16),
                  _extraText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.textColor, width: 2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColor.textColor, size: 120),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColor.objects),
    );

    return TextField(
      style: const TextStyle(color: AppColor.textColor),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColor.textColor),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed: () async {
        debugPrint("Email: ${usernameController.text}");
        debugPrint("Password: ${passwordController.text}");
        await login();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColor.textColor,
        backgroundColor: AppColor.primary,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.textColor),
        ),
      ),
    );
  }
  // change 1
  Widget _extraText() {
    return const Text(
      "Don't have an account? Contact your institution's system administrator.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, color: AppColor.textColor),
    );
  }
}
