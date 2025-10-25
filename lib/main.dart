import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar_widget.dart';

import 'providers/theme_provider.dart';
import 'providers/event_provider.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/sync_button.dart';
import 'widgets/event_form_dialog.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
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
           title: 'MCal: Mobile Calendar',
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: themeProvider.themeMode,
           home: const MyHomePage(title: 'MCal: Mobile Calendar'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: const [
          SyncButton(),
          ThemeToggleButton(),
        ],
      ),
      body: const CalendarWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final selectedDate = context.read<EventProvider>().selectedDate;
          showDialog(
            context: context,
            builder: (context) => EventFormDialog(
              defaultDate: selectedDate,
              onSave: (event) => context.read<EventProvider>().addEvent(event),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }



}
