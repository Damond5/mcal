import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'providers/event_provider.dart';
import 'widgets/event_list.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Consumer<EventProvider>(
                builder: (context, eventProvider, child) => TableCalendar(
                  key: ValueKey(eventProvider.refreshCounter),
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  weekNumbersVisible: true,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                   eventLoader: (day) => eventProvider.getEventsForDate(day).isNotEmpty ? [day] : [],
                 onDaySelected: (selectedDay, focusedDay) {
                   setState(() {
                     _selectedDay = selectedDay;
                     _focusedDay = focusedDay;
                   });
                   context.read<EventProvider>().setSelectedDate(selectedDay);
                 },
                 onPageChanged: (focusedDay) {
                   setState(() {
                     _focusedDay = focusedDay;
                   });
                 },
                  calendarStyle: CalendarStyle(
                    cellMargin: const EdgeInsets.all(4.0),
                    cellPadding: const EdgeInsets.all(2.0),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    defaultTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    outsideTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

              ),
            ),
            if (_selectedDay != null) ...[
              const SizedBox(height: 20),
              EventList(selectedDate: _selectedDay!),
            ],
           ],
         ),
       ),
     );
   }
}