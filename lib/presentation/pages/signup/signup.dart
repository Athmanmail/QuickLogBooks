import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

import '../../../core/configs/theme/appcolor.dart';
import '../home_page/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || contact.isEmpty || password.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Generate a 6-digit verification code
      String verificationCode = _generateVerificationCode();

      // Store user info and verification code in Firestore
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'contact': contact,
        'emailVerified': false,
        'verificationCode': verificationCode,
        'codeCreatedAt': FieldValue.serverTimestamp(),
      });

      // Send the verification code to the user's email
      await _sendVerificationCodeEmail(
        email: email,
        code: verificationCode,
        displayName: name,
        appName: "e_logbook", // Replace with your app name
      );

      _showMessage(
        "A verification code has been sent to $email. Please check your inbox.",
        success: true,
      );

      // Sign out the user until they verify their email
      await FirebaseAuth.instance.signOut();

      // Show verification code input dialog
      _showVerificationCodeDialog(email);
    } catch (e) {
      _showMessage("Signup failed: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateVerificationCode() {
    return (100000 + Random().nextInt(900000)).toString(); // 6-digit code
  }

  Future<void> _sendVerificationCodeEmail({
    required String email,
    required String code,
    required String displayName,
    required String appName,
  }) async {
    // Configure SMTP server (e.g., Gmail)
    final smtpServer = gmail('athmanismilan23@gmail.com', 'xrlq qbak fwwb swnw');

    // Create the email message
    final message = Message()
      ..from = Address('athmanismilan23@gmail.com', appName)
      ..recipients.add(email)
      ..subject = 'Verify Your Email Address'
      ..html = '''
        <p>Hello $displayName,</p>
        <p>Please use the following code to verify your email address:</p>
        <p><strong>$code</strong></p>
        <p>If you didn’t ask to verify this address, you can ignore this email.</p>
        <p>Thanks,</p>
        <p>Your $appName team</p>
      ''';

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending email: $e');
      throw Exception('Failed to send verification email: $e');
    }
  }

  void _showVerificationCodeDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verify Your Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "A 6-digit code has been sent to $email. Please enter it below.",
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String enteredCode = _codeController.text.trim();
              if (enteredCode.isEmpty) {
                _showMessage("Please enter the verification code");
                return;
              }

              // Sign in to get the user
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Check the verification code in Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('admin')
                      .doc(user.uid)
                      .get();

                  String? storedCode = userDoc.get('verificationCode');

                  if (enteredCode == storedCode) {
                    // Update Firestore to mark email as verified
                    await FirebaseFirestore.instance
                        .collection('admin')
                        .doc(user.uid)
                        .update({
                      'emailVerified': true,
                      'verificationCode': null,
                      'codeCreatedAt': null,
                    });

                    Navigator.of(context).pop(); // Close the dialog
                    _showMessage("Email verified successfully!", success: true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(
                          title: _nameController.text.trim(),
                          userName: '',
                        ),
                      ),
                    );
                  } else {
                    _showMessage("Invalid verification code. Please try again.");
                  }
                }
              } catch (e) {
                _showMessage("Error verifying code: $e");
              }
            },
            child: const Text("Verify Code"),
          ),
          TextButton(
            onPressed: () async {
              // Resend a new verification code
              try {
                String newCode = _generateVerificationCode();
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('admin')
                      .doc(user.uid)
                      .update({
                    'verificationCode': newCode,
                    'codeCreatedAt': FieldValue.serverTimestamp(),
                  });

                  await _sendVerificationCodeEmail(
                    email: email,
                    code: newCode,
                    displayName: _nameController.text.trim(),
                    appName: "e_logbook", // Replace with your app name
                  );
                  _showMessage(
                    "A new verification code has been sent to $email.",
                    success: true,
                  );
                }
              } catch (e) {
                _showMessage("Failed to resend verification code: $e");
              }
            },
            child: const Text("Resend Code"),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign Up',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                  fontSize: 32,
                ),
              ),
              const Divider(height: 5, color: AppColor.primary),
              const SizedBox(height: 10),
              Text(
                "Create your account",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColor.light)
                      : const Text('Sign Up', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Log In"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}