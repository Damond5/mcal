import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar_widget.dart';
import 'models/event.dart';
import 'providers/theme_provider.dart';
import 'providers/event_provider.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/sync_button.dart';

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
      context.read<EventProvider>().loadAllEventDates();
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
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final eventProvider = context.read<EventProvider>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    DateTime selectedDate = eventProvider.selectedDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Date: '),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      selectedDate = date;
                    }
                  },
                  child: Text('${selectedDate.month}/${selectedDate.day}/${selectedDate.year}'),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Time: '),
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      selectedTime = time;
                    }
                  },
                  child: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                ),
              ],
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final eventTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                final event = Event(
                  title: titleController.text,
                  time: eventTime,
                  description: descriptionController.text,
                  date: selectedDate,
                );
                context.read<EventProvider>().addEvent(event);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

}
