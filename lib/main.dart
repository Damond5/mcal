import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';
import 'calendar_widget.dart';

import 'providers/theme_provider.dart';
import 'providers/event_provider.dart';
import 'services/notification_service.dart';
import 'services/background_sync_service.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/sync_button.dart';
import 'widgets/event_form_dialog.dart';
import 'frb_generated.dart';
import 'utils/error_logger.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return BackgroundSyncService.executePeriodicSync();
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  if (!Platform.isLinux) {
    Workmanager().initialize(callbackDispatcher);
  }
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<EventProvider>().autoSyncOnResume();
    }
  }

  Future<void> _initNotifications() async {
    tz_data.initializeTimeZones();
    await NotificationService().initialize();
    final granted = await NotificationService().requestPermissions();
    if (!granted && mounted) {
      logGuiError(
        'Notification permissions denied',
        context: 'notification_permissions',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification permissions denied. Events will not notify.',
          ),
        ),
      );
    }
    if (mounted) {
      await context.read<EventProvider>().loadAllEvents();
      if (mounted) {
        await context.read<EventProvider>().autoSyncOnStart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: const [SyncButton(), ThemeToggleButton()],
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
