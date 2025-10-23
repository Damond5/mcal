import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar_widget.dart';
import 'providers/theme_provider.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'widgets/theme_toggle_button.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Simple Calendar',
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const MyHomePage(title: 'Simple Calendar'),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: const CalendarWidget(),
    );
  }
}
