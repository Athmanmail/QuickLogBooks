import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/configs/theme/appcolor.dart';
import '../Activities/activities.dart';
import '../Home/Home.dart';
import '../Login_page/login_page.dart';
import '../notifications/Notifications.dart';
import '../profile/profile.dart';
import '../tasks/tasks.dart';
import '../theme_notifier/theme_notifier.dart';

class MyHomePage extends StatefulWidget {
  final String title; // This will now be the user's name
  final String userName;

  const MyHomePage({super.key, required this.title, required this.userName});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      HomeContent(),
      Activities(),
      Tasks(),
      ProfilePage(userName: widget.userName),
      NotificationsPage(),
    ];
  }

  String getScreenTitle() {
    switch (index) {
      case 0:
        return 'Quick LogBooks';
      case 1:
        return 'Activities';
      case 2:
        return 'Tasks';
      case 3:
        return 'Profile';
      case 4:
        return 'Notifications';
      default:
        return '';
    }
  }

  List<Widget> buildNavItems() {
    return [
      Icon(index == 0 ? Icons.home : Icons.home_outlined, size: 30),
      Icon(index == 1 ? Icons.edit_note : Icons.edit_note_outlined, size: 30),
      Icon(index == 2 ? Icons.task : Icons.task_outlined, size: 30),
      Icon(index == 3 ? Icons.person : Icons.person_outline_rounded, size: 30),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: screens[index],
      appBar: AppBar(
        title: Text(
          getScreenTitle(), // Display the current page title
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColor.light.withOpacity(0.1),
          child: ListView(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    'E-logbooks',
                    style: TextStyle(fontSize: 35),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home', style: TextStyle(fontSize: 20)),
                onTap: () {
                  setState(() {
                    index = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Activities', style: TextStyle(fontSize: 20)),
                onTap: () {
                  setState(() {
                    index = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.task),
                title: const Text('Tasks', style: TextStyle(fontSize: 20)),
                onTap: () {
                  setState(() {
                    index = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications', style: TextStyle(fontSize: 20)),
                onTap: () {
                  setState(() {
                    index = 4;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings', style: TextStyle(fontSize: 20)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile', style: TextStyle(fontSize: 20)),
                onTap: () {
                  setState(() {
                    index = 3;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share', style: TextStyle(fontSize: 20)),
                onTap: () {
                  setState(() {
                    index = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout', style: TextStyle(fontSize: 20)),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false); // End session

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  themeNotifier.value == ThemeMode.light
                      ? CupertinoIcons.moon
                      : CupertinoIcons.sun_max_fill,
                ),
                title: Text(
                  themeNotifier.value == ThemeMode.light ? 'Dark Mode' : 'Light Mode',
                  style: const TextStyle(fontSize: 20),
                ),
                onTap: () {
                  themeNotifier.toggleTheme(themeNotifier.value != ThemeMode.dark);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: index <= 3
          ? NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Theme.of(context).brightness == Brightness.light
              ? AppColor.navbarLight
              : AppColor.navbarLight,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColor.navbarLight
              : AppColor.navbarDark,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColor.navbarLight
              : AppColor.navbarLight,
          buttonBackgroundColor: AppColor.navbarLight,
          height: 60,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 350),
          index: index,
          items: buildNavItems(),
          onTap: (index) => setState(() => this.index = index),
        ),
      )
          : null,
    );
  }
}

class MyHomeStatelessPage extends StatelessWidget {
  final String title;
  final String userName;

  const MyHomeStatelessPage({
    super.key,
    required this.title,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title - Welcome, $userName')),
      body: Center(
        child: Text('Hello $userName, this is your dashboard!'),
      ),
    );
  }
}