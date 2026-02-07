import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'sync':
        return await BackgroundSyncService.executePeriodicSync();
      case 'showNotification':
        return await NotificationService.showNotificationFromWork(inputData);
      default:
        return Future.value(false);
    }
  });
}

void main() async {
  print('MCAL main() started - VERY EARLY LOG');
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
    log('initState() - Adding post-frame callback...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        log('Post-frame callback executing');
        _initNotifications();
      } catch (e, stack) {
        log('Post-frame callback failed: $e');
        log('Stack trace: $stack');
      }
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
    try {
      log('=== _initNotifications() STARTED ===');

      log('Step 1: Calling NotificationService.initialize()');
      await NotificationService().initialize();
      log('Step 1: ✓ NotificationService initialized');

      log('Step 2: Requesting permissions');
      final granted = await NotificationService().requestPermissions();
      if (!granted) {
        logGuiError(
          'Notification permissions denied',
          context: 'notification_permissions',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notification permissions denied. Events will not notify. '
                'You can enable notifications later in Settings > Apps > MCAL > Notifications.',
              ),
              duration: Duration(seconds: 8),
            ),
          );
        }
      }
      log('Step 2: ✓ Permissions requested (granted: $granted)');

      log('Step 3: Loading events on launch');
      await context.read<EventProvider>().loadAllEvents();
      log('Step 3: ✓ Events loaded');

      if (mounted) {
        log('Step 4: Running auto sync on start');
        await context.read<EventProvider>().autoSyncOnStart();
        log('Step 4: ✓ Auto sync completed');
      }

      log('=== _initNotifications() COMPLETED SUCCESSFULLY ===');
    } catch (e, stack) {
      log('=== _initNotifications() FAILED ===');
      log('Error: $e');
      log('Stack trace: $stack');
      logGuiError(
        'Failed to initialize notifications',
        error: e,
        stackTrace: stack,
        context: 'notification_initialization',
      );
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
      floatingActionButton: Semantics(
        label: 'Add Event',
        child: FloatingActionButton(
          onPressed: () {
            final selectedDate = context.read<EventProvider>().selectedDate;
            showDialog(
              context: context,
              builder: (context) => EventFormDialog(
                defaultDate: selectedDate,
                onSave: (event) =>
                    context.read<EventProvider>().addEvent(event),
              ),
            );
          },
          tooltip: 'Add Event',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
