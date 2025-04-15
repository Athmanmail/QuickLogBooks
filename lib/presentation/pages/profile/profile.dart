import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/configs/theme/appcolor.dart';
import '../Login_page/login_page.dart';
import '../theme_notifier/theme_notifier.dart';

// Edit Profile Page (for updating the name)
class EditProfilePage extends StatefulWidget {
  final VoidCallback onUpdate; // Callback to refresh ProfilePage
  const EditProfilePage({super.key, required this.onUpdate});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String _currentName = "";
  String? _docId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid) // Use UID directly
            .get();

        if (doc.exists) {
          setState(() {
            _currentName = doc['name'] ?? "User Name";
            _nameController.text = _currentName;
            _docId = user.uid;
          });
        }
      }
    } catch (e) {
      _showMessage("Error fetching user data: $e");
    }
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      _showMessage("Please enter a name");
      return;
    }

    if (newName == _currentName) {
      _showMessage("No changes made");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_docId != null) {
        await FirebaseFirestore.instance
            .collection('admin')
            .doc(_docId)
            .update({'name': newName});

        _showMessage("Name updated successfully!", success: true);
        widget.onUpdate(); // Trigger refresh on ProfilePage
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage("Failed to update name: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile Name',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Update your full name",
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColor.light)
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Change Password Page
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    if (newPassword.length < 6) {
      _showMessage("New password must be at least 6 characters long");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password in Firebase Auth
        await user.updatePassword(newPassword);

        _showMessage("Password updated successfully!", success: true);
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage("Failed to update password: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your current and new password",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
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
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColor.light)
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Change Email Page
class ChangeEmailPage extends StatefulWidget {
  final VoidCallback onUpdate; // Callback to refresh ProfilePage
  const ChangeEmailPage({super.key, required this.onUpdate});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _docId;
  String _currentEmail = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _currentEmail = doc['email'] ?? "user@example.com";
            _emailController.text = _currentEmail;
            _docId = user.uid;
          });
        }
      }
    } catch (e) {
      _showMessage("Error fetching user data: $e");
    }
  }

  Future<void> _changeEmail() async {
    final newEmail = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (newEmail.isEmpty || password.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
      _showMessage("Please enter a valid email address");
      return;
    }

    if (newEmail == _currentEmail) {
      _showMessage("No changes made");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // Update email in Firebase Auth
        await user.verifyBeforeUpdateEmail(newEmail);

        // Update email in Firestore
        if (_docId != null) {
          await FirebaseFirestore.instance
              .collection('admin')
              .doc(_docId)
              .update({'email': newEmail});
        }

        _showMessage("Email updated successfully! Please verify your new email.", success: true);
        widget.onUpdate(); // Trigger refresh on ProfilePage
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage("Failed to update email: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      appBar: AppBar(
        title: const Text("Change Email"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Email Address',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your new email and password to confirm",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'New Email',
                  prefixIcon: Icon(Icons.email),
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
                  onPressed: _isLoading ? null : _changeEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColor.light)
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Settings Page (Example: Allow toggling a theme setting)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  String? _docId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _docId = user.uid;
        });
      }
    } catch (e) {
      _showMessage("Error fetching user data: $e");
    }
  }

  Future<void> _updateSettings(bool isDarkMode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_docId != null) {
        await FirebaseFirestore.instance
            .collection('admin')
            .doc(_docId)
            .update({'darkMode': isDarkMode});

        _showMessage("Settings updated successfully!", success: true);
      }
    } catch (e) {
      _showMessage("Failed to update settings: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Customize your app settings",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: themeNotifier.value == ThemeMode.dark,
                onChanged: (value) {
                  themeNotifier.toggleTheme(value);
                  _updateSettings(value); // Save to Firestore immediately
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _updateSettings(themeNotifier.value == ThemeMode.dark),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColor.light)
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Preferences Page (Example: Allow toggling notifications)
// class PreferencesPage extends StatefulWidget {
//   const PreferencesPage({super.key});
//
//   @override
//   State<PreferencesPage> createState() => _PreferencesPageState();
// }
//
// class _PreferencesPageState extends State<PreferencesPage> {
//   bool _notificationsEnabled = true;
//   bool _isLoading = false;
//   String? _docId;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchPreferences();
//   }
//
//   Future<void> _fetchPreferences() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('admin')
//             .doc(user.uid)
//             .get();
//
//         if (doc.exists) {
//           if (doc.data() != null) {
//             final data = doc.data() as Map<String, dynamic>;
//             setState(() {
//               _notificationsEnabled = data.containsKey('notificationsEnabled')
//                   ? data['notificationsEnabled'] as bool
//                   : true;
//               _docId = user.uid;
//             });
//           } else {
//             setState(() {
//               _notificationsEnabled = true;
//               _docId = user.uid;
//             });
//             await FirebaseFirestore.instance
//                 .collection('admin')
//                 .doc(user.uid)
//                 .set({
//               'notificationsEnabled': _notificationsEnabled,
//             }, SetOptions(merge: true));
//           }
//         } else {
//           await FirebaseFirestore.instance
//               .collection('admin')
//               .doc(user.uid)
//               .set({
//             'notificationsEnabled': _notificationsEnabled,
//           }, SetOptions(merge: true));
//           setState(() {
//             _docId = user.uid;
//           });
//         }
//       } else {
//         _showMessage("User not authenticated");
//       }
//     } catch (e) {
//       _showMessage("Error fetching preferences: $e");
//       print("Error details: $e");
//     }
//   }
//
//   Future<void> _updatePreferences() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       if (_docId != null) {
//         Map<String, dynamic> updates = {
//           'notificationsEnabled': _notificationsEnabled,
//         };
//
//         if (_notificationsEnabled) {
//           String? fcmToken = await NotificationService.getFCMToken();
//           if (fcmToken != null) {
//             updates['fcmToken'] = fcmToken;
//             // Show a test notification only on supported platforms
//             if (Platform.isAndroid || Platform.isIOS) {
//               await NotificationService.showNotification(
//                 "Notifications Enabled",
//                 "You have successfully enabled notifications!",
//               );
//             }
//           } else {
//             _showMessage("Failed to retrieve FCM token. Notifications may not work.");
//           }
//         } else {
//           updates['fcmToken'] = FieldValue.delete();
//         }
//
//         await FirebaseFirestore.instance
//             .collection('admin')
//             .doc(_docId)
//             .set(updates, SetOptions(merge: true));
//
//         _showMessage("Preferences updated successfully!", success: true);
//       } else {
//         _showMessage("User document ID not found");
//       }
//     } catch (e) {
//       _showMessage("Failed to update preferences: $e");
//       print("Error updating preferences: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//     }
//
//
//   void _showMessage(String message, {bool success = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//       backgroundColor: success ? Colors.green : Colors.red,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text("Preferences"),
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Preferences',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.primary,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Manage your app preferences",
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//               const SizedBox(height: 30),
//               SwitchListTile(
//                 title: const Text("Enable Notifications"),
//                 value: _notificationsEnabled,
//                 onChanged: (value) {
//                   setState(() {
//                     _notificationsEnabled = value;
//                   });
//                   _updatePreferences();
//                 },
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _updatePreferences,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColor.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: AppColor.light)
//                       : const Text('Save', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ProfilePage
class ProfilePage extends StatefulWidget {
  final String userName;
  const ProfilePage({super.key, required this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Loading...";
  String email = "Loading...";
  String contact = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            name = doc['name'] ?? "User Name";
            email = doc['email'] ?? "user@example.com";
            contact = doc['contact'] ?? "N/A";
          });
        }
      }
    } catch (e) {
      _showMessage("Error fetching user data: $e");
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false); // End session

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      _showMessage("Logout failed: $e");
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // children: [
                //   IconButton(
                //     icon: const Icon(Icons.arrow_back, color: Colors.black),
                //     onPressed: () => Navigator.pop(context),
                //   ),
                //   IconButton(
                //     icon: const Icon(Icons.edit, color: Colors.black),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => EditProfilePage(onUpdate: _fetchUserData),
                //         ),
                //       );
                //     },
                //   ),
                // ],
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColor.primary,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "U",
                  style: const TextStyle(fontSize: 40, color: AppColor.light),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Edit Profile Name"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(onUpdate: _fetchUserData),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Change Email Address"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeEmailPage(onUpdate: _fetchUserData),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
              // const Divider(),
              // ListTile(
              //   leading: const Icon(Icons.star),
              //   title: const Text("Preferences"),
              //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const PreferencesPage()),
              //     );
              //   },
              // ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}