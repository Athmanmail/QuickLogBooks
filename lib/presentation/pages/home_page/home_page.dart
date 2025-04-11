import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/configs/theme/appTheme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);

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
          home: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: Icon(
                    mode == ThemeMode.light
                        ? CupertinoIcons.moon
                        : CupertinoIcons.sun_max_fill,
                  ),
                  onPressed: () {
                    _notifier.value = mode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                ),
              ],
            ),
            body: const Center(
              child: Text("Hello, Flutter!"),
            ),
          ),
        );
      },
    );
  }
}
