import 'package:e_logbook/core/configs/theme/appcolor.dart';
import 'package:e_logbook/presentation/pages/Activities/activities.dart';
import 'package:e_logbook/presentation/pages/Home/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/configs/theme/appTheme.dart';
import '../notifications/Notifications.dart';
import '../profile/profile.dart';
import '../tasks/tasks.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);
  int index = 0;

  final screens = [
    HomeContent(),
    Activities(),
    Tasks(),
    ProfilePage(),
    NotificationsPage(),
  ];

  String getScreenTitle() {
    switch (index) {
      case 0:
        return 'Home';
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _notifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: screens[index],
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      getScreenTitle(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              drawer: Drawer(
                child: Container(
                  color: AppColor.menu.withOpacity(0.1),
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
                        title:
                        const Text('Activities', style: TextStyle(fontSize: 20)),
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
                          setState(() {
                            index = 2;
                          });
                          Navigator.pop(context);
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
                        onTap: () {
                          setState(() {
                            index = 2;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          mode == ThemeMode.light
                              ? CupertinoIcons.moon
                              : CupertinoIcons.sun_max_fill,
                        ),
                        title: Text(
                          mode == ThemeMode.light ? 'Dark Mode' : 'Light Mode',
                          style: const TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          _notifier.value = mode == ThemeMode.light
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        },
                      ),

                    ],
                  ),
                ),
              ),
              bottomNavigationBar:  index <= 3 ? NavigationBarTheme(
                data: NavigationBarThemeData(
                  indicatorColor: Theme.of(context).brightness == Brightness.light
                      ? AppColor.light
                      : AppColor.navbarLight, // You can also customize this for dark/light
                  backgroundColor: Theme.of(context).brightness == Brightness.light
                      ? AppColor.navbarLight
                      : AppColor.navbarDark, // <- dynamic background
                  labelTextStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                ),
                child: NavigationBar(
                  height: 60,
                  // backgroundColor: AppColor.navbar,
                  labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
                  selectedIndex: index,
                  animationDuration: const Duration(microseconds: 30),
                  onDestinationSelected: (index) =>
                      setState(() => this.index = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.edit_note_outlined),
                      selectedIcon: Icon(Icons.edit_note),
                      label: 'Activities',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.task_outlined),
                      selectedIcon: Icon(Icons.task),
                      label: 'Tasks',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ): null,
            ),
          ),
        );
      },
    );
  }
}
